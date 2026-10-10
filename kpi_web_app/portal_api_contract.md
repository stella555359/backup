# Portal API Contract

## 1. Document Scope

This document describes the current Portal contract implemented by `kpi-dashboard/portal`.

It covers:

- page-level responsibilities
- HTTP routes exposed by each blueprint
- adapter responsibilities and key methods
- Portal input schema objects
- persisted job structure and artifact mapping

This is a Portal-facing contract document, not the internal algorithm contract of sibling repositories.

## 2. Page Contract

### 2.1 Portal home

- page purpose: module navigation entry
- template: `portal/templates/home.html`
- route: `GET /`
- data source: `repo_registry.get_module_cards()`
- output shape per module card:
  - `key`
  - `title`
  - `summary`
  - `route_name`
  - `repo_exists`
  - `readme_exists`
  - `entry_count`
  - `repo_path`

### 2.2 Detector module page

- page purpose: upload KPI Excel files, validate naming, browse detector jobs, filter and operate on history
- template: `portal/templates/modules/kpi_detector.html`
- route root: `/kpi-anomaly-detector`
- UI characteristics:
  - file upload
  - base-file switch
  - filename override support
  - filter form
  - paged job list
  - rerun, cancel, delete, bulk actions

### 2.3 Detector job detail page

- page purpose: inspect a detector job and related artifacts/logs
- template: `portal/templates/modules/kpi_detector_job.html`
- route: `GET /kpi-anomaly-detector/jobs/<job_id>`
- expected view data:
  - `module`
  - `job`
  - `stdout_tail`
  - `stderr_tail`
  - `auto_refresh`

### 2.4 Generator module page

- page purpose: submit generator jobs or scout conversion jobs, then inspect history
- template: `portal/templates/modules/kpi_generator.html`
- route root: `/kpi-generator`
- UI characteristics:
  - generator mode and scout conversion mode
  - build, environment, scenario inputs
  - template set or template list inputs
  - report timestamp inputs
  - optional auto-detector follow-up

### 2.5 Generator job detail page

- page purpose: inspect generator output and optionally linked detector job
- template: `portal/templates/modules/kpi_generator_job.html`
- route: `GET /kpi-generator/jobs/<job_id>`
- expected view data:
  - `module`
  - `job`
  - `linked_detector_job`
  - `auto_refresh`

### 2.6 Traffic model module page

- page purpose: inspect env resolution, choose UEs, assemble traffic plan, and submit orchestrated traffic jobs
- template: `portal/templates/modules/kpi_traffic_model.html`
- route root: `/kpi-traffic-model`
- UI characteristics:
  - env lookup
  - dynamic UE selection
  - stage and item form inputs
  - runtime option flags
  - recent job list

### 2.7 Traffic model job detail page

- page purpose: inspect submitted request and resulting execution state
- template: `portal/templates/modules/kpi_traffic_model_job.html`
- route: `GET /kpi-traffic-model/jobs/<job_id>`
- expected view data:
  - `module`
  - `job`
  - `auto_refresh`

## 3. Route Contract

## 3.1 Portal blueprint

### `GET /`

- handler: `portal.home`
- response: HTML home page
- source data: repository module cards

### `GET /healthz`

- handler: `portal.healthz`
- response: JSON health payload
- response fields:
  - `status`
  - `service`
  - `job_store_backend`

## 3.2 Detector blueprint

Base prefix: `/kpi-anomaly-detector`

### `GET /`

- handler: `kpi_detector.index`
- purpose: list page with filters and jobs
- query params:
  - `q`
  - `status`
  - `release`
  - `environment`
  - `scenario`
  - `page`

### `POST /submit`

- handler: `kpi_detector.submit`
- purpose: submit one or more `.xlsx` uploads
- form fields:
  - `files` or `file`
  - `is_base_file`
  - `filename_override_environment`
  - `filename_override_scenario`
- response behavior:
  - flash message + redirect
  - single accepted job redirects to job detail

### `POST /validate-upload-filenames`

- handler: `kpi_detector.validate_upload_filenames`
- request body: JSON with `filenames`
- response JSON:
  - `invalid_filenames`
  - `requires_override`

### `GET /jobs/<job_id>`

- handler: `kpi_detector.job_detail`
- response: HTML detail page

### `POST /jobs/<job_id>/rerun`

- handler: `kpi_detector.rerun`
- purpose: requeue job from historical input

### `POST /jobs/bulk/rerun`

- handler: `kpi_detector.bulk_rerun`
- form fields:
  - `job_ids`
  - current filter state fields for redirect continuity

### `POST /jobs/<job_id>/cancel`

- handler: `kpi_detector.cancel`
- purpose: cancel running or queued job when supported

### `POST /jobs/<job_id>/delete`

- handler: `kpi_detector.delete`
- purpose: remove job metadata and related history references

### `POST /jobs/bulk/delete`

- handler: `kpi_detector.bulk_delete`
- purpose: delete multiple selected jobs

### `GET /api/jobs/<job_id>`

- handler: `kpi_detector.job_status`
- response: JSON job payload plus log tails
- additional fields added on top of job object:
  - `stdout_tail`
  - `stderr_tail`

### `GET /jobs/<job_id>/artifacts/<artifact_kind>`

- handler: `kpi_detector.artifact`
- purpose: download or display primary artifact kinds or report assets

### `GET /jobs/<job_id>/detail-artifacts/<artifact_kind>/<item_index>`

- handler: `kpi_detector.detail_artifact`
- purpose: fetch per-detail output items, such as per-record HTML or Excel

### `GET /jobs/<job_id>/artifacts/<path:asset_path>`

- handler: `kpi_detector.artifact_asset`
- purpose: serve nested static assets referenced by report HTML

## 3.3 Generator blueprint

Base prefix: `/kpi-generator`

### `GET /`

- handler: `kpi_generator.index`
- purpose: list generator jobs and show submit form
- query params:
  - `q`
  - `status`
  - `environment`
  - `scenario`
  - `page`

### `POST /jobs`

- handler: `kpi_generator.submit`
- purpose: create generator or scout conversion job
- key form fields for generator mode:
  - `job_mode=generator`
  - `template_set_name`
  - `template_names`
  - `build`
  - `environment`
  - `scenario`
  - `report_timestamps_list`
  - `timestamp_delta_minutes`
  - `auto_detector`
  - `auto_detector_is_base_file`
- key form fields for scout conversion mode:
  - `job_mode=scout_conversion`
  - `build`
  - `environment`
  - `scenario`
  - `dist_name_filter`
  - `scout_report`
  - `auto_detector`
  - `auto_detector_is_base_file`

### `GET /jobs/<job_id>`

- handler: `kpi_generator.job_detail`
- response: HTML detail page

### `POST /jobs/<job_id>/rerun`

- handler: `kpi_generator.rerun`
- purpose: recreate job from previous request context

### `POST /jobs/<job_id>/cancel`

- handler: `kpi_generator.cancel`

### `POST /jobs/<job_id>/delete`

- handler: `kpi_generator.delete`

### `GET /api/jobs/<job_id>`

- handler: `kpi_generator.job_status`
- response: JSON job payload

### `GET /jobs/<job_id>/artifacts/<artifact_kind>`

- handler: `kpi_generator.artifact`
- purpose: fetch generated report bundle or result artifacts

## 3.4 Traffic model blueprint

Base prefix: `/kpi-traffic-model`

### `GET /`

- handler: `kpi_traffic_model.index`
- purpose: show env inspection and recent jobs
- query params:
  - `env`

### `GET /api/resolve-env`

- handler: `kpi_traffic_model.resolve_env_api`
- query params:
  - `env`
- response:
  - success: env inspection JSON
  - error: `400` with `error`

### `POST /jobs`

- handler: `kpi_traffic_model.submit`
- purpose: create traffic-model orchestration job
- input characteristics:
  - env selection
  - UE selection list
  - runtime flags
  - traffic stage/item assembly fields
- response behavior:
  - flash + redirect to detail page on success

### `GET /jobs/<job_id>`

- handler: `kpi_traffic_model.job_detail`

### `GET /api/jobs/<job_id>`

- handler: `kpi_traffic_model.job_status`
- response: JSON job payload

### `GET /jobs/<job_id>/artifacts/<artifact_kind>`

- handler: `kpi_traffic_model.artifact`

### `POST /jobs/<job_id>/delete`

- handler: `kpi_traffic_model.delete`

## 4. Adapter Contract

## 4.1 Common adapter role

All module adapters are responsible for the same high-level contract:

- describe the module to the UI
- provide a sample local command
- normalize input into module-specific execution parameters
- create and persist Portal job records
- launch or coordinate real work in sibling repositories
- map runtime outputs back into Portal-visible artifacts and job states

`portal/adapters/base.py` provides common behavior such as:

- `ModuleRepository`
- `describe_module()`
- `sample_command()`
- shared module metadata formatting
- integration mode declaration

## 4.2 Detector adapter contract

Key methods observed in `portal/adapters/kpi_detector.py`:

- `sample_command()`
- `describe_module()`
- `filter_options()`
- `query_jobs()`
- `validate_filename()`
- `submit()`
- `submit_existing_file()`
- `get_job()`
- `list_jobs()`
- `rerun()`
- `cancel()`
- `delete()`
- `read_job_log_tail()`
- `artifact_path()`
- `report_asset_path()`
- `detail_artifact_path()`
- `recover_startup_jobs()`

Special contract notes:

- detector input validity is derived from filename convention
- module supports bulk operations in the blueprint layer
- module exposes both top-level artifacts and nested report assets

## 4.3 Generator adapter contract

Key methods observed in `portal/adapters/kpi_generator.py`:

- `sample_command()`
- `describe_module()`
- `filter_options()`
- `query_jobs()`
- `submit()`
- `submit_scout_conversion()`
- `submit_scout_conversion_from_path()`
- `get_job()`
- `list_jobs()`
- `rerun()`
- `cancel()`
- `delete()`
- `artifact_path()`
- `recover_startup_jobs()`

Special contract notes:

- supports two job modes: generator and scout conversion
- can auto-trigger detector follow-up work
- job detail page may show linked detector job

## 4.4 Traffic model adapter contract

Key methods observed in `portal/adapters/kpi_traffic_model.py`:

- `sample_command()`
- `describe_module()`
- `inspect_env()`
- `submit_request()`
- `get_job()`
- `list_jobs()`
- `delete()`
- `artifact_path()`

Special contract notes:

- environment inspection is a first-class contract
- submission input is a structured request payload, not only raw file upload

## 5. Input Schema Contract

Portal input schemas are defined in `portal/schemas/input_models.py`.

## 5.1 Common fields

### `PortalJobCommonFields`

- `job_mode: str`
- `build: Optional[str]`
- `environment: Optional[str]`
- `scenario: Optional[str]`

### `PortalRuntimeOptions`

- `as_base_file: bool = False`
- `auto_detector: bool = False`
- `auto_detector_is_base_file: bool = False`
- `auto_generator: bool = False`
- `dry_run: bool = False`
- `stop_on_failure: bool = True`
- `max_parallel_workers: Optional[int] = None`
- `log_level: Optional[str] = None`
- `timeout_seconds: Optional[int] = None`

## 5.2 Detector input

### `DetectorPortalInput`

- `common: PortalJobCommonFields`
- `runtime_options: PortalRuntimeOptions`
- `original_filename: str`
- `source_generator_job_id: Optional[str] = None`

Builder contract:

- created through `from_filename(...)`
- depends on filename parsing callback
- raises `InputValidationError` if filename does not match expected rule

## 5.3 Generator input

### `GeneratorPortalInput`

- `common: PortalJobCommonFields`
- `runtime_options: PortalRuntimeOptions`
- `template_set_name: str`
- `template_names: List[str]`
- `report_timestamps_text: str`
- `timestamp_delta_minutes: Optional[int]`

Builder contract:

- created through `from_submission(...)`
- validates template selection, build, env, scenario, timestamps, and delta rules

### `GeneratorScoutPortalInput`

- `common: PortalJobCommonFields`
- `runtime_options: PortalRuntimeOptions`
- `dist_name_filter: str`
- `dist_name_filters: List[str]`
- `scout_report_original_filename: str = 'scout_report.xlsx'`

Builder contract:

- created through `from_submission(...)`
- validates `.xlsx` input and non-empty DistName filters

## 5.4 Traffic model input

### `TrafficModelPortalInput`

- `common: PortalJobCommonFields`
- `runtime_options: PortalRuntimeOptions`
- `selected_ue_indexes: List[int]`
- `same_type_execution_mode: str = 'serial'`
- `cross_type_execution_mode: str = 'serial'`
- `stage_execution_mode: str = 'serial'`

Builder contract:

- created through `from_form(...)`
- validates env, selected UE list, positive worker count, and execution mode values

## 6. Job Persistence Contract

Portal jobs are created in `portal/services/job_store.py` by `create_job(...)` and then enriched by adapters.

## 6.1 Common stored fields

Fields created immediately at job creation:

- `id`
- `module_key`
- `original_filename`
- `stored_filename`
- `is_base_file`
- `queue_order`
- `status`
- `created_at`
- `started_at`
- `completed_at`
- `error_message`
- `process_pid`
- `cancel_requested_at`
- `input_path`
- `stdout_log_path`
- `stderr_log_path`
- `result_json_path`
- `report_html_path`
- `report_excel_path`
- `report_data_path`
- `stats`
- `current_record`

Observed status values in route behavior include at least:

- `queued`
- `running`

Terminal states are adapter-defined and may vary by module.

## 6.2 Persistence backends

The job store supports:

- SQLite backend
- file-based fallback backend

SQLite schema includes:

- `jobs`
- `job_events`
- `job_links`
- `job_artifacts`

## 6.3 Artifact mapping

Common artifact kinds derived in `job_store.py` include:

- `request`
- `stdout`
- `stderr`
- `result`
- `report_html`
- `report_excel`
- `report_data`
- `report`
- `source`

These kinds are derived from job fields such as:

- `input_path`
- `stdout_log_path`
- `stderr_log_path`
- `result_json_path`
- `report_html_path`
- `report_excel_path`
- `report_data_path`
- `report_file_path`
- `scout_report_path`

## 6.4 Linked job contract

The job store derives cross-job links from fields such as:

- `detector_job_id`
- `source_generator_job_id`

Derived link kinds include:

- `auto_detector`
- `source_generator`

This is how the Portal represents workflow chaining across modules.

## 7. Module Metadata Contract

`portal/contracts.py` defines normalized metadata objects.

### `ModuleCapabilityContract`

- `supports_cancel`
- `supports_delete`
- `supports_rerun`
- `supports_preview`
- `supports_auto_trigger`
- `supports_status_api`

### `JobContract`

- `module_key`
- `statuses`
- `artifact_kinds`
- `progress_fields`
- `linked_job_fields`

### `SummaryContract`

- `result_payload_key`
- `summary_fields`
- `ui_fields`

These contracts are the normalization point for exposing different modules through one Portal UI model.

## 8. Contract Summary

The Portal contract can be summarized in one line:

browser pages and HTTP routes remain stable, while adapters absorb sibling-repository differences and the job store persists normalized operational state.

That is the main structural reason this Portal can aggregate detector, generator, and traffic-model capabilities in one Flask application.