from prefect.client.orchestration import get_client
from prefect.client.schemas.filters import FlowRunFilter, LogFilter
import asyncio

async def trigger_deployment():
    async with get_client() as client:
        # Fetch the last deployment
        deployments = await client.read_deployments()
        last_deployment = deployments[-1]  # Assuming this is the correct logic to fetch the last one
        print(f"Last Deployment ID: {last_deployment.id}")

        # Run the last deployment
        flow_run = await client.create_flow_run_from_deployment(
            deployment_id=last_deployment.id
        )
        print(f"Flow Run ID: {flow_run.id}")

        # Wait for flow run to complete (simple polling logic)
        while True:
            flow_run_state = (await client.read_flow_run(flow_run.id)).state.name
            if flow_run_state in {"Completed", "Failed", "Cancelled"}:
                break
            print(f"Current state: {flow_run_state}. Waiting to complete...")
            await asyncio.sleep(10)

        # Retrieve logs from the flow run
        logs_filter = LogFilter(flow_run_id={"any_": [str(flow_run.id)]})
        logs = await client.read_logs(log_filter=logs_filter)
        
        for log in logs:
            print(f"{log.timestamp} - {log.level}: {log.message}")

# Run the asyncio event loop
asyncio.run(trigger_deployment())
