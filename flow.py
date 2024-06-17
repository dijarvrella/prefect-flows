import asyncio
from prefect import flow
from prefect_docker.images import pull_docker_image
from prefect_docker.containers import create_docker_container, start_docker_container
from prefect_docker.credentials import DockerRegistryCredentials

@flow
async def pull_and_run_nginx():
    # Load Docker credentials
    docker_registry_credentials = await DockerRegistryCredentials.load("seedoo-docker-registry")

    # Pull the latest nginx image from the private repository
    image = await pull_docker_image(
        repository="seedooinsights/build",
        tag="11ba042",
        docker_registry_credentials=docker_registry_credentials
    )
    print(f"Pulled image: {image}")

    # Create and run a container from the pulled image
    container = await create_docker_container(
        image="seedooinsights/build:11ba042",
        command=["tail", "-f", "/dev/null"]
    )
    print(f"Created container: {container}")

    # Start the container
    started_container = await start_docker_container(container_id=container.id)
    print(f"Started container: {started_container}")

if __name__ == "__main__":
    asyncio.run(pull_and_run_nginx())