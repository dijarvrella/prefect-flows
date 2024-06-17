# Prefect Flows
This repository contains the code for the Prefect flows that are used in the project.

## Description

This project uses Prefect to manage and run workflows. The main flow, `pull_and_run_nginx`, is defined in `flow.py`. This flow pulls the latest nginx Docker image and runs a container from it.

The Prefect flow is configured and deployed using the settings in `prefect.yaml`.

## Getting Started

To get started with this project, you need to have Docker and Prefect installed on your machine.

1. Clone this repository.
2. Build the Docker image using the provided Dockerfile.
3. Run the Prefect flow using the Prefect CLI.

## License

This project is licensed under the terms of the LICENSE file.

## Contributing

Contributions are welcome! Please read the contributing guidelines before getting started.

## Contact

If you have any questions, feel free to reach out.
