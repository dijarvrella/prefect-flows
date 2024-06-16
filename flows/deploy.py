from prefect import flow

from prefect.runner.storage import GitRepository
from prefect_github import GitHubCredentials

if __name__ == "__main__":
    print("Starting to deploy flow from source...")
    try:
        flow.from_source(
            source=GitRepository(
                url="https://github.com/dijarvrella/prefect-flows",
                credentials=GitHubCredentials.load("dv")
            ),
            entrypoint="prefect-flows-main/flows/create_container.py:create_docker_container_flow",
        ).deploy(
            name="create-container-from-git-deployment",
            work_pool_name="seedoo-container-worker",
            build=False
        )
        print("Flow successfully deployed.")
    except Exception as e:
        print(f"Error occurred: {e}")
