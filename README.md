# README.md

This repository contains the code for a hands-on demo that shows how to proactively detect "gray failures" in a serverless application. We use a combination of **Terraform** for infrastructure, **OpenTelemetry (OTel)** for observability, and **AWS DevOps Guru** for AIOps analysis.

The goal is to show how an AIOps platform can find subtle performance issues that traditional, threshold-based alarms would miss.

---

## 🆚 Modular (Terragrunt) Approaches

**Benefits:**
- True environment isolation: each environment (dev, prod, etc.) has its own state, config, and outputs.
- Project-wide, environment, and module-level configuration is DRY and clearly separated (`project.hcl`, `env.hcl`, `root.hcl`).
- All major AWS resources (Lambda, API Gateway, DynamoDB, IAM, DevOps Guru) are reusable Terraform modules in `terraform/modules/`.
- Each environment folder (e.g., `demo/envs/dev/`) contains only wiring and dependencies, not resource logic.
- Adding a new environment is as simple as copying an env folder and changing a few variables.
- Outputs and variables are easily aggregated and consumed across modules using Terragrunt's `--all` and `include` features.
- Easy to extend for new AWS services or environments with minimal duplication.
- Follows latest Terragrunt best practices (no root terragrunt.hcl, uses `root.hcl`, etc.).
- Scalable, maintainable, and ready for real-world multi-environment cloud deployments.

**You can still use the old approach** by running Terraform directly in the `terraform/` folder, but the recommended and supported way is now via Terragrunt in the `demo/dev/` folder for all new development and deployments.

---

## **Prerequisites**

Before you start, you'll need a few things:

- An **AWS Account** with the necessary permissions.
- **Terragrunt** (required for orchestrating the modular infrastructure)
- **Terraform** (used by Terragrunt under the hood)
- **jq** (for parsing JSON output from Terragrunt)
- **hey** (for load generation/traffic simulation)
- **Python 3.12**
- **Python Pip**

Install Terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/
Install jq: https://stedolan.github.io/jq/download/

---

## **🚀 Setup and Deployment (Terragrunt Modular Approach)**

1. Go to the `demo/dev` folder (or your chosen environment):

    ```bash
    cd demo/envs/dev
    ```

2. **Deploy the Stack with Terragrunt:**

    Terragrunt will orchestrate all modules (Lambda, API Gateway, DynamoDB, IAM, DevOps Guru) using DRY, environment-specific configuration.

    ```bash
    terragrunt init --all
    terragrunt plan  --all
    terragrunt run-all apply --auto-approve
    ```

3. **Get the API Endpoint:**

    After deployment, use Terragrunt to output the API endpoint URL. Export it to a shell variable to make it easier to use.

    ```bash
    terragrunt output -json --all  | jq -r 'to_entries[] | select(.key | test("api_endpoint")) | .value.value'
    export API_URL=$(terragrunt output -json --all  | jq -r 'to_entries[] | select(.key | test("api_endpoint")) | .value.value')
    echo $API_URL
    ```

---

## **🔬 Running the Experiment**

This experiment has three phases: establishing a baseline, injecting a failure, and observing the detection.

### **1. Generate Baseline Traffic (The "Good" State)**

First, we need to show DevOps Guru what "normal" looks like. We'll run a steady stream of traffic against our endpoint for a few hours to establish a baseline.

```bash
# Run for 2-4 hours to establish a good baseline
hey -z 4h -q 5 -m POST "$API_URL"
```


### 2. Inject the "Gray Failure"

Now, we'll introduce a subtle performance degradation.

- In `demo/dev/serverless_app/terragrunt.hcl` (or the relevant Lambda module config), set the environment variable `INJECT_LATENCY` to `"true"` in the `environment_variables` input map.

- Apply the change:

    ```bash
    terragrunt apply --all
    ```

This will trigger a quick update to the Lambda function. This deployment event is also a signal that DevOps Guru will use in its analysis.

### 3. Generate Anomaly Traffic & Observe

With the latency now active, run the same load generation command again.

```bash
# Run for at least 30-60 minutes to generate enough anomalous data
hey -z 1h -q 5 -m POST "$API_URL"
```

After some time (typically 30-90 minutes), navigate to the **AWS DevOps Guru console**. You should see a new "insight" that has detected the high latency in the Lambda function and correlated it with the recent deployment.

---

## 🧹 Cleanup

To avoid ongoing costs, destroy the infrastructure when you're done:

```bash
terragrunt destroy --all
```
---

## 🧩 DRY Configuration

- Common values (like app name, tags, Lambda source paths) are defined once in `demo/dev/terragrunt.hcl` and referenced in all modules.
- Each module's `terragrunt.hcl` uses `include` and `local.<var>` to stay DRY and environment-specific.

---

## Terragrunt Modular & Environment-Aware Setup

### Configuration Structure

- **Root `root.hcl`**: Defines provider and backend generation for all modules. Uses `local.app_name` and `local.environment` for S3 backend isolation.
- **`demo/project.hcl`**: Sets Project Locals, like `app_name_prefix`, `project_name`
- **`demo/envs/dev/env.hcl`**: Sets Project Environment, like `environment`

### Example: Adding a New Environment

```bash
cp -r demo/envs/dev demo/envs/prod
# Edit demo/envs/prod/terragrunt.hcl:
#   - Set environment = "prod"
#   - Set app_name = "aiops-demo-prod"
```
