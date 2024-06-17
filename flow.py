import asyncio
from prefect import flow
from prefect_docker.images import pull_docker_image
from prefect_docker.containers import create_docker_container, start_docker_container
from prefect_docker.credentials import DockerRegistryCredentials

@flow
async def pull_and_run_image():
    # Load Docker credentials
    docker_registry_credentials = await DockerRegistryCredentials.load("seedoo-docker-registry")

    # Pull the latest image from the private repository
    image = await pull_docker_image(
        repository="seedooinsights/build",
        tag="11ba042",
        docker_registry_credentials=docker_registry_credentials
    )
    print(f"Pulled image: {image}")

    # Create a container with the specified flags
    container = await create_docker_container(
        image="seedooinsights/build:11ba042",
        command=["python", "test.py"],
        volumes=[
            f"/opt/prefect/test.py:/workspace/test.py",
            "/seedoodata:/seedoodata",
        ],
        device_requests=[
            {
                'Driver': 'nvidia',
                'Count': -1,
                'Capabilities': [['gpu']],
            },
        ],
        group_add=["seedoo"],
        detach=True,
        tty=True,
        stdin_open=True,  # -it is a combination of -i (interactive) and -t (tty)
        cap_add=["SYSLOG"]
    )
    print(f"Created container: {container}")

    # Start the container
    started_container = await start_docker_container(container_id=container.id)
    print(f"Started container: {started_container}")

if __name__ == "__main__":
    asyncio.run(pull_and_run_image())