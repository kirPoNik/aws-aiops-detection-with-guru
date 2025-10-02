# README.md

This repository contains the code for a hands-on demo that shows how to proactively detect "gray failures" in a serverless application. We use a combination of **Terraform** for infrastructure, **OpenTelemetry (OTel)** for observability, and **AWS DevOps Guru** for AIOps analysis.

The goal is to show how an AIOps platform can find subtle performance issues that traditional, threshold-based alarms would miss.

---

## **Prerequisites**

Before you start, you'll need a few things:

- An **AWS Account** with the necessary permissions.
- **Terraform** installed on your machine.
- **hey** installed for load generation.

---

## **🚀 Setup and Deployment**

1. Go to the `terraform` folder
    
    ```bash
    cd aiops-proactive-detection-demo/terraform
    ```
    
2. **Deploy the Stack:** Run the standard Terraform commands to deploy the infrastructure (API Gateway, Lambda, DynamoDB, and DevOps Guru configuration).
    
    ```bash
    terraform init
    terraform apply --auto-approve
    ```
    
3. **Get the API Endpoint:** After deployment, Terraform will output the API endpoint URL. Export it to a shell variable to make it easier to use.
    
    ```bash
    export API_URL=$(terraform output -raw api_endpoint)
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

- In `terraform/main.tf`, find the `aws_lambda_function` resource.
- In the `environment` variables block, change `INJECT_LATENCY` from `"false"` to `"true"`.
- Apply the change:
    
    ```bash
    terraform apply --auto-approve
    ```
    

This will trigger a quick update to the Lambda function. This deployment event is also a signal that DevOps Guru will use in its analysis.

### 3. Generate Anomaly Traffic & Observe

With the latency now active, run the same load generation command again.

Bash

```bash
# Run for at least 30-60 minutes to generate enough anomalous data
hey -z 1h -q 5 -m POST "$API_URL"
```

After some time (typically 30-90 minutes), navigate to the **AWS DevOps Guru console**. You should see a new "insight" that has detected the high latency in the Lambda function and correlated it with the recent deployment.

---

## 🧹 Cleanup

To avoid ongoing costs, destroy the infrastructure when you're done.

Bash

```bash
terraform destroy --auto-approve
```
