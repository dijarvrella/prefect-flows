import asyncio
from prefect import flow
from prefect_docker.images import pull_docker_image
from prefect_docker.containers import create_docker_container

@flow
async def pull_and_run_nginx():
    # Pull the latest nginx image
    image = await pull_docker_image(repository="nginx", tag="latest")
    print(f"Pulled image: {image}")

    # Create and run a container from the pulled image
    container = await create_docker_container(
        image="nginx:latest",
        command=["nginx", "-g", "daemon off;"]
    )
    print(f"Created container: {container}")

if __name__ == "__main__":
    asyncio.run(pull_and_run_nginx())