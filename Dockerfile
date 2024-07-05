# Use the specified base image
FROM prefecthq/prefect:2-latest-conda

# Set environment variables
ENV PREFECT_API_URL=http://localhost:4200/api
ENV PREFECT_SERVER_API_HOST=0.0.0.0

COPY flow.py .
COPY worker-base-job-template.yaml .
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Install necessary Python packages
RUN pip install prefect-docker prefect-github requests==2.31.0
RUN apt-get update && \
    apt-get install -y docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to the script
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/usr/local/bin/entrypoint.sh"]