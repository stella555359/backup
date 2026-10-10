# KPI Web App Rebuild Request Specification

## 1. Document Purpose

This document defines the complete requirement input package needed to rebuild the `kpi_web_app` project from scratch in a way that is closest to the current repository family.

The goal is not to describe implementation details first. The goal is to define what a product owner, business analyst, architect, and domain expert must provide before development can start with low ambiguity.

The current project family includes at least these capability domains:

- Portal shell: `kpi-dashboard`
- KPI anomaly detection capability: `kpi-anomaly-detector`
- KPI report generation capability: `kpi-generator`
- Testline-driven traffic orchestration capability: `kpi_traffic_model`
- Supporting scripts and report tools: `get-kpi-report`

Therefore, the requirement package must describe both the Portal and the capability modules that the Portal orchestrates.

## 2. Product Definition to Be Clarified Up Front

Before implementation, the requester must clearly define the product boundary.

### 2.1 Product positioning

The requester must state whether the target system is:

1. A unified KPI Portal only
2. A Portal plus local execution engine for KPI tools
3. A Portal plus remote service orchestration platform
4. An internal engineering analysis platform for test and KPI workflows

### 2.2 Product scope statement

The requester must define:

- Which modules are in scope for phase 1
- Which modules are postponed
- Whether the Portal is only a UI shell or must also own orchestration, scheduling, persistence, and audit functions
- Whether sibling repositories remain independent or are merged into a single product

### 2.3 Target users

The requester must specify all user personas, for example:

- KPI analysts
- Test engineers
- CI operators
- Portal administrators
- Data maintainers
- Developers
- Release managers

For each persona, the requester must provide:

- Main goals
- Allowed operations
- Data visibility scope
- Expected output type

## 3. Required Requirement Input Domains

To rebuild the project properly, the requester must provide requirement input in the following domains.

### 3.1 Business capability requirements

The requester must provide the business capability list in modular form.

Each capability must include:

- Capability name
- Business objective
- Trigger condition
- Input artifacts
- Processing rule
- Output artifacts
- Failure handling expectation
- Owner team

Example capabilities in the current project shape:

- Upload KPI Excel files and run anomaly detection
- Generate Compass KPI reports by time range and template set
- Resolve testline environment and build traffic model requests
- Persist Portal-side jobs and execution status
- Visualize output reports and downloadable artifacts

### 3.2 Functional requirements

The requester must provide complete functional requirements using use-case or user-story format.

For each function, provide:

- Function ID
- Function name
- Actor
- Preconditions
- Main flow
- Alternate flow
- Exception flow
- Postconditions
- Acceptance criteria

The minimum set should cover:

- Portal home page behavior
- Module navigation behavior
- File upload and validation
- Background job creation
- Job queueing and execution state transitions
- Job detail page rendering
- Report and artifact download behavior
- Rerun, cancel, and delete rules
- Module health and repository binding visibility
- Traffic model env inspection and request submission

### 3.3 Data requirements

The requester must provide a structured data requirement specification.

This must include:

- Input data source types
- Input file naming conventions
- Required file formats
- Required data columns and schema rules
- Data validation rules
- Derived fields and calculation rules
- Output data schema
- Retention rules
- Versioning rules

For this project family, the requester must explicitly define:

- KPI source Excel schema
- Historical comparison rules
- Detector filename parsing rules
- Generator request payload schema
- Traffic model request schema
- Job metadata schema
- Artifact metadata schema
- Event timeline schema

### 3.4 Integration requirements

The requester must provide all upstream and downstream integrations.

For each integration, provide:

- System name
- Integration type: local CLI, Python import, HTTP API, database, file share, message queue
- Direction: inbound or outbound
- Authentication mode
- Timeout rule
- Retry rule
- Failure behavior
- Contract versioning rule

Based on the current project structure, likely integrations include:

- `kpi-anomaly-detector` local Python execution
- `kpi-generator` local Python execution
- `kpi_traffic_model` request generation and execution handoff
- Compass login and template APIs
- Local file system report directories
- Portal SQLite job metadata store
- Optional Robot or testline-related external execution environments

### 3.5 UI and interaction requirements

The requester must provide UI requirements beyond simple screenshots.

Each page must define:

- Page objective
- Entry route
- Core components
- User operations
- Validation rules
- Table columns
- Filter and search behavior
- Auto-refresh behavior
- Empty state
- Error state
- Success messaging
- Download behavior

For the current Portal shape, the minimum pages are:

- Home page
- KPI detector index page
- KPI detector job detail page
- KPI generator index page
- KPI generator job detail page
- KPI traffic model index page
- KPI traffic model job detail page

### 3.6 Workflow and orchestration requirements

The requester must describe workflow semantics, not just screens.

For each asynchronous workflow, define:

- Trigger source
- Queueing policy
- Concurrency rule
- Ordering rule
- Timeout rule
- Cancellation semantics
- Recovery after process restart
- Rerun semantics
- Artifact collection points
- Final state conditions

This is critical because the Portal is not only a display app. It is a job-oriented orchestration shell.

### 3.7 Non-functional requirements

The requester must provide measurable non-functional targets.

Minimum categories:

- Performance: upload size, max concurrent jobs, page response SLA
- Availability: service uptime target
- Reliability: restart recovery behavior
- Scalability: expected number of users, jobs, artifacts
- Security: authentication, authorization, secret management, audit
- Maintainability: logging level, test coverage expectations, module isolation
- Deployability: target OS, reverse proxy, systemd, TLS, runtime path
- Observability: metrics, logs, alert rules

### 3.8 Operational requirements

The requester must define how the system is operated in production.

This includes:

- Deployment environment model: dev, test, prod
- Configuration source: env vars, config file, secret store
- Backup policy
- Cleanup policy
- Log retention
- Artifact retention
- Database maintenance
- Rollback strategy
- Release process

### 3.9 Security and compliance requirements

The requester must explicitly define:

- Whether login is needed
- Whether RBAC is needed
- Who can upload, rerun, cancel, delete
- Secret storage method
- Audit event requirements
- Sensitive file handling rules
- Internal network access assumptions

### 3.10 Acceptance and validation requirements

The requester must define acceptance from both business and engineering perspectives.

Minimum acceptance layers:

- Functional acceptance
- UI acceptance
- Integration acceptance
- Data correctness acceptance
- Performance acceptance
- Deployment acceptance
- Operations acceptance

## 4. Required Requirement Input Template

The requester should ideally fill the following sections before implementation.

## 4.1 Project charter

- Project name
- Business owner
- Technical owner
- Sponsor
- Target release milestone
- Scope summary
- Out-of-scope summary

## 4.2 Module inventory

For each module:

- Module name
- Description
- Business owner
- User type
- Input type
- Output type
- Execution mode: synchronous, asynchronous, background job
- Dependency systems

## 4.3 Use-case matrix

For each use case:

- Use case ID
- Actor
- Trigger
- Preconditions
- Input
- Main steps
- Error branches
- Output
- Acceptance criteria

## 4.4 Data contract matrix

For each input and output artifact:

- Artifact name
- Producer
- Consumer
- Format
- Naming rule
- Required fields
- Validation rules
- Retention policy

## 4.5 Integration contract matrix

For each dependency:

- Dependency name
- Interface type
- Call direction
- Auth mode
- Timeout
- Retry
- Error mapping
- Owner team

## 4.6 Page specification matrix

For each UI page:

- Route
- Purpose
- Main component list
- User actions
- State transitions
- API or backend dependency
- Success and failure feedback

## 4.7 Environment and deployment matrix

- OS target
- Python version
- Web runtime
- Reverse proxy choice
- Database choice
- Storage path rules
- Secret source
- Monitoring stack
- Deployment method

## 5. Domain-Specific Requirement Inputs Needed for This Project

To match the current `kpi_web_app` family closely, the requester must provide the following domain-specific information.

### 5.1 For KPI Anomaly Detector

- Exact upload file naming contract
- How environment, build, and scenario are parsed from filenames
- History matching rules
- Base file and non-base file behavior
- Detector timeout rules
- Report types required: HTML, Excel, JSON summary
- Summary fields required on Portal job list and detail pages
- Rerun and replacement rules

### 5.2 For KPI Generator

- Compass-side report generation flow
- Required template selection logic
- Template set source and cache rule
- Time range semantics
- Horizontal merge or compare semantics
- Final report packaging rules

### 5.3 For KPI Traffic Model

- Environment resolution rules
- Testline or UE selection rules
- Execution model options: serial, parallel, stage-based
- Attach or detach semantics
- Dry run semantics
- Follow-up behavior to generator or detector
- Artifact outputs expected from one job

### 5.4 For Portal Runtime Layer

- Job persistence rules
- Event timeline semantics
- Artifact indexing rules
- Restart recovery semantics
- Cancel and delete permission rules
- Prefix deployment requirements under nginx

## 6. Recommended Requirement Elicitation Process

To organize the above professionally, the requirement process should follow this sequence.

### Phase 1: product scoping

Output:

- Product vision
- Scope boundary
- Module inventory
- Stakeholder list

### Phase 2: domain workflow discovery

Output:

- Current operational process map
- External systems map
- Pain point list
- Manual vs automated boundary

### Phase 3: functional decomposition

Output:

- Use-case catalog
- Workflow state machine
- UI page map
- Core service responsibilities

### Phase 4: data and integration contract definition

Output:

- Data dictionary
- Naming conventions
- Integration contracts
- Error handling contracts

### Phase 5: non-functional and deployment specification

Output:

- Environment matrix
- Performance constraints
- Security policy
- Deployment topology
- Monitoring and logging plan

### Phase 6: acceptance definition

Output:

- UAT checklist
- Engineering completion checklist
- Go-live gate conditions

## 7. What the Requester Must Actually Hand Over

The most practical answer is the following.

If the requester wants a team to rebuild `kpi_web_app` accurately, the requester must hand over this full package:

1. Product vision and scope statement
2. Module list and priorities
3. User personas and permissions
4. Full use-case catalog
5. Input and output data contracts
6. All naming rules and parsing rules
7. All external system integrations and access assumptions
8. UI page requirements and interactions
9. Workflow state transitions and background job semantics
10. Database or persistence requirements
11. Deployment environment and runtime requirements
12. Security, audit, and compliance rules
13. Acceptance criteria and test scenarios

Without this package, the rebuilt product will likely become a technically working system that does not match operational reality.

## 8. Final Recommendation

For this project family, the best requirement baseline is not a single PRD paragraph. It should be a requirement set composed of:

- PRD
- Use-case specification
- Data contract specification
- Integration specification
- UI page specification
- Workflow state machine specification
- NFR and deployment specification

That is the most complete and professional input set required to rebuild a project shaped like `kpi_web_app`.
