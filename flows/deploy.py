from prefect import flow

if __name__ == "__main__":
    flow.from_source(
        "https://github.com/dijarvrella/prefect-flows",
        entrypoint="flows/create_container.py:create_docker_container_flow",
    ).deploy(
        name="create-container-deployment",
        work_pool_name="seedoo-container-worker",
        build=False
    )
