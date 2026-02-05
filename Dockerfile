FROM alpine:3.19 AS builder

ARG WIKI_REPO=https://github.com/OI-wiki/OI-wiki.git
ARG PYPI_MIRROR=https://pypi.org/simple/

RUN apk add --no-cache \
    git bash curl python3 py3-pip nodejs yarn \
    gcc g++ make musl-dev python3-dev ca-certificates

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /build
RUN git clone ${WIKI_REPO} --depth=1 .
RUN uv sync --index-url ${PYPI_MIRROR}
RUN yarn --frozen-lockfile
RUN bash ./scripts/pre-build/install-theme.sh
RUN uv run mkdocs build -v

# Remove all external integration
RUN find site -name "*.html" -type f -print0 | xargs -0 sed -i \
    -e '/{OIWikiFeedbackSystemFrontendCSS}/d' \
    -e '/{OIWikiFeedbackSystemFrontendJS}/d' \
    -e '/{OIWikiFeedbackSystemFrontendContentScript}/d' \
    -e '/OIWikiFeedbackSystem/d' \
    -e '/giscus/d' \
    -e '/utterances/d' \
    -e '/gitalk/d'

FROM nginx:alpine
COPY --from=builder /build/site /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
