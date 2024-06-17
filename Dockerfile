# Use the specified base image
FROM prefecthq/prefect:2-latest-conda

# Set environment variables
ENV PREFECT_API_URL=http://localhost:4200/api
ENV PREFECT_SERVER_API_HOST=0.0.0.0

COPY flow.py /opt/prefect/flow.py

# Install necessary Python packages
RUN pip install prefect-docker prefect-github requests==2.31.0

CMD ["tail", "-f", "/dev/null"]