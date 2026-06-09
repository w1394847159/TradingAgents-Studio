import os
import uvicorn


def main():
    host = os.getenv("TRADINGAGENTS_WEB_HOST", "127.0.0.1")
    port = int(os.getenv("TRADINGAGENTS_WEB_PORT", "8087"))
    reload = os.getenv("TRADINGAGENTS_WEB_RELOAD", "true").lower() == "true"

    uvicorn.run(
        "web.backend.main:app",
        host=host,
        port=port,
        reload=reload,
    )


if __name__ == "__main__":
    main()

