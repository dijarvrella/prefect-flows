import asyncio
from prefect import flow, task, get_run_logger
from prefect_docker.images import pull_docker_image
from prefect_docker.containers import create_docker_container, start_docker_container, get_docker_container_logs
from prefect_docker.credentials import DockerRegistryCredentials

@task
async def pull_image(credentials):
  logger = get_run_logger()
  logger.info("Pulling the latest image from the private repository...")
  image = await pull_docker_image(
      repository="seedooinsights/build",
      tag="latest",
      docker_registry_credentials=credentials
  )
  logger.info(f"Pulled image: {image}")
  return image

@task
async def create_container(command_params):
  logger = get_run_logger()
  logger.info("Creating a container with the specified flags...")
  container = await create_docker_container(
    image="seedooinsights/build:latest",
    command=["bash", "-c", command_params],
    volumes=[
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
    stdin_open=True,
    cap_add=["SYSLOG"],
    shm_size="64G"
  )
  logger.info(f"Created container: {container}")
  return container

@task
async def start_container(container_id):
  logger = get_run_logger()
  logger.info(f"Starting container with ID: {container_id}...")
  started_container = await start_docker_container(container_id=container_id)
  logger.info(f"Started container: {started_container}")
  return started_container

@task
async def get_docker_container_logs_flow(container_id):
  logger = get_run_logger()
  logger.info(f"Logs from container with ID: {container_id}...")
  container_logs = await get_docker_container_logs(container_id=container_id)
  return container_logs

@flow
async def pull_and_run_image(command_params):
  logger = get_run_logger()
  logger.info("Loading Docker credentials...")
  docker_registry_credentials = await DockerRegistryCredentials.load("seedoo-docker-registry")

  image = await pull_image(docker_registry_credentials)
  logger.info(f"Pulled image: {image}")

  container = await create_container(command_params)
  logger.info(f"Created container: {container}")

  started_container = await start_container(container.id)
  logger.info(f"Started container: {started_container}")

  # Get the container logs
  await asyncio.sleep(20)  # Add a 10 second sleep
  container_logs = await get_docker_container_logs_flow(container.id)
  logger.info(f"Container logs: {container_logs}")

if __name__ == "__main__":
  asyncio.run(pull_and_run_image(command_params="echo HEYYYYYYYY"))