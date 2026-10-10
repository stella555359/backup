from __future__ import annotations

import argparse
import asyncio
import html
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path

from PIL import Image
from playwright.async_api import async_playwright
from pptx import Presentation
from pptx.util import Inches


SOURCE_HTML = Path(__file__).with_name("earth_speech_presentation_boy_en.html")
STATIC_PPTX = Path(__file__).with_name(
    "earth_speech_presentation_boy_en_static.pptx"
)
DYNAMIC_PPTX = Path(__file__).with_name(
    "earth_speech_presentation_boy_en_dynamic.pptx"
)

SLIDE_COUNT = 8
STATIC_VIEWPORT = (1600, 900)
DYNAMIC_VIEWPORT = STATIC_VIEWPORT
DYNAMIC_CROP_SIZE = 320
DYNAMIC_FPS = 8
DYNAMIC_DURATION_MS = 4000

SPEECH_TEXTS = (
    "My Speech: The Earth. Presented by Sunny.",
    "Hello, everyone! Today, I want to talk about the Earth.",
    "The Earth is a big blue ball! It has blue seas, and green land.",
    "We live on the Earth!",
    "We can see many stars, and the moon, at night.",
    "The sun is hot and bright! It gives us light, and warm sunshine.",
    "We have only one Earth. I love the Earth!",
    "Thank you, everyone!",
)

EDGE_PATHS = (
    Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
    Path(r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"),
)


@dataclass(frozen=True)
class DynamicOverlay:
    image: Path
    left_px: float
    top_px: float
    width_px: float
    height_px: float


EXPORT_CSS = """
html, body {
    margin: 0 !important;
    width: 100% !important;
    height: 100% !important;
    overflow: hidden !important;
}
body {
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
}
.decorations,
.bottom-bar {
    display: none !important;
}
.presentation-container {
    width: 100% !important;
    max-width: none !important;
    height: 100vh !important;
    max-height: none !important;
    border: 0 !important;
    border-radius: 0 !important;
    box-shadow: none !important;
}
.top-bar {
    padding: 22px 42px !important;
}
.slide {
    padding: 52px 90px !important;
    gap: 72px !important;
    transition: none !important;
}
.slide .english-txt {
    animation: none !important;
}
.slide[data-index="0"] .sub-txt span {
    display: none !important;
}
.rotate-earth {
    animation-duration: 4s !important;
}
.pulse {
    animation-duration: 2s !important;
}
.shake {
    animation-duration: 4s !important;
}
.twinkle {
    animation-duration: 2s !important;
}
"""


def edge_executable() -> Path:
    for candidate in EDGE_PATHS:
        if candidate.exists():
            return candidate
    raise FileNotFoundError("Microsoft Edge was not found.")


async def prepare_page(
    browser,
    viewport: tuple[int, int],
    device_scale_factor: int = 1,
):
    page = await browser.new_page(
        viewport={"width": viewport[0], "height": viewport[1]},
        device_scale_factor=device_scale_factor,
    )
    await page.goto(SOURCE_HTML.resolve().as_uri(), wait_until="load")
    try:
        await page.evaluate("document.fonts.ready")
    except Exception:
        pass
    await page.add_style_tag(content=EXPORT_CSS)
    return page


async def show_slide(page, slide_index: int) -> None:
    await page.evaluate(
        """index => {
            goToSlide(index);
            document.querySelectorAll('.slide').forEach((slide, current) => {
                slide.classList.toggle('active', current === index);
            });
        }""",
        slide_index,
    )
    await page.wait_for_timeout(100)


async def capture_static_slides(browser, output_dir: Path) -> list[Path]:
    page = await prepare_page(browser, STATIC_VIEWPORT)
    outputs: list[Path] = []
    try:
        for index in range(SLIDE_COUNT):
            await show_slide(page, index)
            await page.wait_for_timeout(650)
            await page.evaluate(
                """() => document.getAnimations().forEach(animation => {
                    animation.pause();
                })"""
            )
            output = output_dir / f"static_slide_{index + 1:02d}.png"
            await page.screenshot(path=str(output), type="png")
            outputs.append(output)
    finally:
        await page.close()
    return outputs


async def capture_dynamic_slides(
    browser,
    output_dir: Path,
) -> list[DynamicOverlay]:
    page = await prepare_page(
        browser,
        DYNAMIC_VIEWPORT,
        device_scale_factor=2,
    )
    outputs: list[DynamicOverlay] = []
    frame_duration_ms = round(1000 / DYNAMIC_FPS)
    frame_count = DYNAMIC_DURATION_MS // frame_duration_ms

    try:
        for index in range(SLIDE_COUNT):
            await show_slide(page, index)
            frame_dir = output_dir / f"frames_{index + 1:02d}"
            frame_dir.mkdir()

            await page.evaluate(
                """() => document.getAnimations().forEach(animation => {
                    animation.pause();
                    animation.currentTime = 0;
                })"""
            )

            svg = page.locator(".slide.active .visual-area svg").first
            svg_box = await svg.bounding_box()
            if svg_box is None:
                raise RuntimeError(f"Could not locate animated artwork on slide {index + 1}.")

            crop_size = DYNAMIC_CROP_SIZE
            center_x = svg_box["x"] + svg_box["width"] / 2
            center_y = svg_box["y"] + svg_box["height"] / 2
            clip = {
                "x": max(0, min(center_x - crop_size / 2, DYNAMIC_VIEWPORT[0] - crop_size)),
                "y": max(0, min(center_y - crop_size / 2, DYNAMIC_VIEWPORT[1] - crop_size)),
                "width": crop_size,
                "height": crop_size,
            }

            frame_paths: list[Path] = []
            for frame_index in range(frame_count):
                current_time = frame_index * frame_duration_ms
                await page.evaluate(
                    """time => document.getAnimations().forEach(animation => {
                        animation.pause();
                        animation.currentTime = time;
                    })""",
                    current_time,
                )
                frame_path = frame_dir / f"frame_{frame_index:03d}.png"
                await page.screenshot(
                    path=str(frame_path),
                    type="png",
                    clip=clip,
                )
                frame_paths.append(frame_path)

            output = output_dir / f"dynamic_slide_{index + 1:02d}.gif"
            frames = [Image.open(path).convert("RGB") for path in frame_paths]
            frames[0].save(
                output,
                save_all=True,
                append_images=frames[1:],
                duration=frame_duration_ms,
                loop=0,
                disposal=2,
                optimize=True,
            )
            for frame in frames:
                frame.close()
            outputs.append(
                DynamicOverlay(
                    image=output,
                    left_px=clip["x"],
                    top_px=clip["y"],
                    width_px=clip["width"],
                    height_px=clip["height"],
                )
            )
    finally:
        await page.close()
    return outputs


async def render_assets(
    output_dir: Path,
) -> tuple[list[Path], list[DynamicOverlay]]:
    async with async_playwright() as playwright:
        browser = await playwright.chromium.launch(
            executable_path=str(edge_executable()),
            headless=True,
            args=(
                "--allow-file-access-from-files",
                "--disable-web-security",
                "--font-render-hinting=none",
            ),
        )
        try:
            static_slides = await capture_static_slides(browser, output_dir)
            dynamic_slides = await capture_dynamic_slides(browser, output_dir)
        finally:
            await browser.close()
    return static_slides, dynamic_slides


def create_image_presentation(
    images: list[Path],
    output: Path,
    title: str,
    subject: str,
) -> None:
    presentation = Presentation()
    presentation.slide_width = Inches(13.333333)
    presentation.slide_height = Inches(7.5)
    blank_layout = presentation.slide_layouts[6]

    for image in images:
        slide = presentation.slides.add_slide(blank_layout)
        slide.shapes.add_picture(
            str(image),
            0,
            0,
            width=presentation.slide_width,
            height=presentation.slide_height,
        )

    properties = presentation.core_properties
    properties.title = title
    properties.subject = subject
    properties.author = "Sunny"
    properties.comments = (
        "Generated from earth_speech_presentation_boy_en.html. "
        "The static version uses PNG slide images. "
        "The dynamic version uses animated GIF slide images."
    )
    presentation.save(output)


def create_dynamic_presentation(
    backgrounds: list[Path],
    overlays: list[DynamicOverlay],
    output: Path,
) -> None:
    if len(backgrounds) != len(overlays):
        raise ValueError("Dynamic backgrounds and overlays must have the same length.")

    presentation = Presentation()
    presentation.slide_width = Inches(13.333333)
    presentation.slide_height = Inches(7.5)
    blank_layout = presentation.slide_layouts[6]
    viewport_width, viewport_height = STATIC_VIEWPORT

    for background, overlay in zip(backgrounds, overlays, strict=True):
        slide = presentation.slides.add_slide(blank_layout)
        slide.shapes.add_picture(
            str(background),
            0,
            0,
            width=presentation.slide_width,
            height=presentation.slide_height,
        )

        left = round(presentation.slide_width * overlay.left_px / viewport_width)
        top = round(presentation.slide_height * overlay.top_px / viewport_height)
        width = round(presentation.slide_width * overlay.width_px / viewport_width)
        height = round(presentation.slide_height * overlay.height_px / viewport_height)
        slide.shapes.add_picture(
            str(overlay.image),
            left,
            top,
            width=width,
            height=height,
        )

    properties = presentation.core_properties
    properties.title = "The Earth - Dynamic Presentation"
    properties.subject = "Crisp static text with animated illustration overlays."
    properties.author = "Sunny"
    properties.comments = (
        "Generated from earth_speech_presentation_boy_en.html. "
        "Each slide uses a high-resolution PNG background and an animated GIF "
        "only over the illustration area, keeping all text sharp."
    )
    presentation.save(output)


def select_sapi_voice(voice):
    preferred_names = ("Zira", "Hazel", "Aria", "Samantha", "Susan")
    tokens = voice.GetVoices()
    for preferred_name in preferred_names:
        for index in range(tokens.Count):
            token = tokens.Item(index)
            if preferred_name.lower() in token.GetDescription().lower():
                voice.Voice = token
                return token.GetDescription()
    for index in range(tokens.Count):
        token = tokens.Item(index)
        description = token.GetDescription().lower()
        if "english" in description:
            voice.Voice = token
            return token.GetDescription()
    return voice.Voice.GetDescription()


def create_narration_files(output_dir: Path) -> tuple[list[Path], str]:
    import win32com.client

    voice = win32com.client.Dispatch("SAPI.SpVoice")
    voice.Rate = -1
    voice.Volume = 100
    selected_voice = select_sapi_voice(voice)
    outputs: list[Path] = []

    for index, text in enumerate(SPEECH_TEXTS, start=1):
        output = output_dir / f"narration_{index:02d}.wav"
        stream = win32com.client.Dispatch("SAPI.SpFileStream")
        stream.Open(str(output), 3, False)
        voice.AudioOutputStream = stream
        expressive_text = (
            "<pitch middle='-2'><rate speed='-1'>"
            f"{html.escape(text)}"
            "</rate></pitch>"
        )
        voice.Speak(expressive_text, 8)
        stream.Close()
        outputs.append(output)

    return outputs, selected_voice


def embed_narration(presentation_path: Path, audio_files: list[Path]) -> None:
    import pythoncom
    import win32com.client

    pythoncom.CoInitialize()
    powerpoint = win32com.client.DispatchEx("PowerPoint.Application")
    powerpoint.Visible = True
    presentation = None
    try:
        presentation = powerpoint.Presentations.Open(
            str(presentation_path.resolve()),
            ReadOnly=False,
            Untitled=False,
            WithWindow=False,
        )
        for index, audio_file in enumerate(audio_files, start=1):
            slide = presentation.Slides(index)
            media = slide.Shapes.AddMediaObject2(
                str(audio_file.resolve()),
                False,
                True,
                918,
                498,
                28,
                28,
            )
            media.Name = f"Narration_{index:02d}"
            play_settings = media.AnimationSettings.PlaySettings
            play_settings.PlayOnEntry = False
            play_settings.HideWhileNotPlaying = False
            play_settings.LoopUntilStopped = False
            play_settings.StopAfterSlides = 1
        presentation.Save()
    finally:
        if presentation is not None:
            presentation.Close()
        powerpoint.Quit()
        pythoncom.CoUninitialize()


def inspect_presentation(path: Path) -> tuple[int, list[str]]:
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
    slides = [name for name in names if name.startswith("ppt/slides/slide") and name.endswith(".xml")]
    media = [name for name in names if name.startswith("ppt/media/")]
    return len(slides), media


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Convert the Earth HTML speech into static and dynamic PPTX files."
    )
    parser.add_argument(
        "--skip-audio",
        action="store_true",
        help="Create the dynamic PPTX without embedded narration.",
    )
    args = parser.parse_args()

    if not SOURCE_HTML.exists():
        raise FileNotFoundError(f"Source HTML not found: {SOURCE_HTML}")

    with tempfile.TemporaryDirectory(prefix="earth_speech_ppt_") as temp:
        temp_dir = Path(temp)
        static_images, dynamic_images = asyncio.run(render_assets(temp_dir))

        create_image_presentation(
            static_images,
            STATIC_PPTX,
            "The Earth - Static Presentation",
            "High-fidelity static slides rendered from the English HTML presentation.",
        )
        create_dynamic_presentation(
            static_images,
            dynamic_images,
            DYNAMIC_PPTX,
        )

        selected_voice = "not generated"
        if not args.skip_audio:
            audio_files, selected_voice = create_narration_files(temp_dir)
            embed_narration(DYNAMIC_PPTX, audio_files)

    static_slide_count, static_media = inspect_presentation(STATIC_PPTX)
    dynamic_slide_count, dynamic_media = inspect_presentation(DYNAMIC_PPTX)
    print(f"Static PPTX: {STATIC_PPTX}")
    print(f"  slides={static_slide_count}, media={len(static_media)}")
    print(f"Dynamic PPTX: {DYNAMIC_PPTX}")
    print(f"  slides={dynamic_slide_count}, media={len(dynamic_media)}")
    print(f"Narration voice: {selected_voice}")


if __name__ == "__main__":
    main()
