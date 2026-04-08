# OpenList PaaS Reloader

[Chinese](./README.md) | English

---

This project is specifically designed for deploying OpenList on PaaS platforms such as Hugging Face and Render. Since these platforms utilize non-persistent file systems, in the absence of a remote database and without the use of keep-alive tools, container restarts or waking from hibernation can lead to a reset of the file system, resulting in the loss of OpenList's storage configuration. This project achieves "pseudo-persistent" operation by automatically injecting configuration from environment variables through scripts in the Dockerfile at startup.

## Script Principle

After the script is launched in the OpenList backend, it first polls the local interface to ensure the service is ready, reads the `OPENLIST_ADMIN_PASSWORD` variable to log in and obtain a Token, then iterates through the `STORAGE_JSON_*` variables, dynamically injects the storage configuration through the API interface, and achieves automatic configuration reloading.

## Quick Start

### 1.  Prepare to store JSON
Export a backup from the OpenList backend, and extract the JSON string of the target object from the `storages` array
- **Requirement**: It must be a standard JSON object `{...}` with no extra comma at the end
- **Suggestion**: Manually delete the `id` field

### 2.  Configure environment variables (Secrets)
Set the following variables in the PaaS platform console:

| Variable Name | Required | Description |
| :--- | :--- | :--- |
| `OPENLIST_ADMIN_PASSWORD` | Yes | Set OpenList admin password |
| `STORAGE_JSON_1` | No | The first storage configuration JSON (such as Tianyi Cloud Disk) |
| `STORAGE_JSON_2` | No | The second storage configuration JSON (such as Quark Cloud Storage) |
| . .. | No | Script support setting up to `STORAGE_JSON_10` |

### 3.  README.md (exclusive for Hugging Face)

The default port for Hugging Face is 7860. Please customize the port number to 5244 at the end of the `README.md` file in Spaces

```
app_port: 5244
```

## Description

- Detailed tutorial: The solution was first published on the blog [Some Thoughts on OpenList and Hugging Face](https://log.1k.ink/p/openlist-huggingface). If you have any questions, please refer to the detailed tutorial on the blog first
- Applicable scenario: This project is an automated solution designed to "attract valuable contributions from others" and is suitable for low-frequency maintenance scenarios
- Advanced recommendation: If you require more frequent data modifications and truly persistent data, it is recommended to use a remote database (MySQL/PostgreSQL) in conjunction
