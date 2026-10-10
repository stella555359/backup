import tkinter as tk
import tkinter.filedialog
import tkinter.messagebox as msgbox
import check_average_throughput


class Window(tk.Tk):
    select_file = "filename"

    def __init__(self):
        super().__init__()
        self.title("Throughput calculate tool")
        self.geometry('500x200')
        self.minsize(450, 180)
        self.maxsize(600, 300)
        self.label_text = tk.StringVar()
        self.label_text.set("Upload aasyslog file, file fomat is txt.\nMust upaload first")

        self.label = tk.Label(
            self,
            font=('Arial', 12, 'bold'),
            bg='sky blue',
            foreground='black',
            textvar=self.label_text)
        self.label.pack(fill=tk.BOTH, expand=1, padx=100, pady=30)

        upload_button = tk.Button(
            self,
            text="Upload Aasyslog File",
            font=('Arial', 12, 'bold'),
            background='yellow',
            foreground='black',
            command=self.upload_file)
        upload_button.pack(side=tk.TOP, padx=(20, 0), pady=(0, 20))

        ul_button = tk.Button(
            self,
            text="Calculate UL Throughput",
            font=('Arial', 11, 'bold'),
            background='light blue',
            foreground='black',
            command=self.Calculate_ul_tupt)
        ul_button.pack(side=tk.LEFT, padx=(20, 20), pady=(0, 20))

        dl_button = tk.Button(
            self,
            text="Calculate DL Throughput",
            font=('Arial', 11, 'bold'),
            background='light blue',
            foreground='black',
            command=self.Calculate_dl_tupt)
        dl_button.pack(side=tk.RIGHT, padx=(0, 20), pady=(0, 20))

    def upload_file(self):
        global select_file
        select_file = tk.filedialog.askopenfilename(filetypes=(("Aasyslog", "*.txt"),))
        msgbox.showinfo("the path of file as below", select_file)

    def Calculate_ul_tupt(self):
        tupt_info = check_average_throughput.get_tput_info_for_l2lo(tput_file=select_file, direction="ul")
        # print("tupt_info is {}".format(tupt_info))
        msgbox.showinfo("the details of ul tupt as below", tupt_info)

    def Calculate_dl_tupt(self):
        tupt_info = check_average_throughput.get_tput_info_for_l2lo(tput_file=select_file, direction="dl")
        msgbox.showinfo("the details of dl tupt as below", tupt_info)


if __name__ == "__main__":
    window = Window()
    window.mainloop()
