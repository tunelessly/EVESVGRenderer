ARG targetDownloadDir=/downloads
ARG outputDir=/database
ARG sourceFile=sqlite-latest.sqlite.bz2
ARG sourceURL=https://www.fuzzwork.co.uk/dump/
ARG appDir=/app/

FROM python:3.11.4-bookworm as base
# Setup
RUN apt update
RUN apt install -y \
    graphviz \
    graphviz-dev \
    sqlite3 \
    build-essential
ARG appDir
ARG targetDownloadDir
ARG outputDir
ARG sourceFile
ARG sourceURL
RUN mkdir ${targetDownloadDir}
RUN mkdir ${outputDir}
# Download the data dump in sqlite format
WORKDIR ${targetDownloadDir}
RUN wget --no-verbose --show-progress --progress=dot:giga ${sourceURL}${sourceFile}
RUN bzip2 -d ${sourceFile}
COPY ./datadump/* ./
RUN chmod +x run.sh
RUN ./run.sh sqlite-latest.sqlite
RUN ls
RUN mv ./database_transformed.sqlite3 ${outputDir}/
RUN rm -rf ${targetDownloadDir}
# Transform the data into SVG 
WORKDIR ${appDir}
RUN pip install poetry
COPY ./evesvgrenderer/ ./evesvgrenderer/
COPY ./output/ ./output/
COPY ./poetry.lock ./pyproject.toml README.md entrypoint.sh ./
RUN poetry install
RUN chmod +x entrypoint.sh
ENV outputDir=${outputDir}
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["sh", "-c", "poetry run start ${outputDir}/database_transformed.sqlite3"]