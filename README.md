# OpenList-PaaS-Reloader

本项目专为 Hugging Face 及 Render 等 PaaS 平台设计。由于此类平台采用非持久化文件系统，在无远程数据库且不使用保活工具时，容器重启或休眠唤醒会导致文件系统重置，从而丢失 OpenList 的存储配置。本项目通过 Dockerfile 里的脚本实现启动时自动从环境变量注入配置，实现“伪持久化”运行。

## 脚本原理

脚本在 OpenList 后台启动后，首先轮询本地接口确保服务就绪，读取环境变量中的密码进行登录并获取 Token，随后循环遍历 STORAGE_JSON_* 变量，通过 API 接口将存储配置动态注入，实现配置自动重载。

## 快速上手

### 1. 准备存储 JSON
在 OpenList 后台导出备份，从 `storages` 数组中提取目标对象的 JSON 字符串。
- **要求**：必须是标准的 JSON 对象 `{...}`，确保末尾无多余逗号。
- **建议**：手动删除 `id` 字段。

### 2. 配置环境变量 ( Secrets )
在 PaaS 平台控制台设置以下变量：

| 变量名 | 必填 | 说明 |
| :--- | :--- | :--- |
| `OPENLIST_ADMIN_PASSWORD` | 是 | 设置 OpenList 管理员密码 |
| `STORAGE_JSON_1` | 否 | 第一个存储配置 JSON（如阿里云盘） |
| `STORAGE_JSON_2` | 否 | 第二个存储配置 JSON（如夸克网盘） |
| ... | 否 | 脚本支持设置至 `STORAGE_JSON_10` |

### 3. README.md（ Hugging Face 专用 ）

Hugging Face默认端口为 7860 ，请在 Spaces 的 `README.md` 末尾自定义端口号为 5244 

```
app_port: 5244
```

## 说明

- 方案首发于博客 [一些有关 OpenList 与 Hugging Face 的小巧思](https://log.1k.ink/p/openlist-huggingface) ，如有疑惑，可先前往博客文章中查看详细教程
- 本项目为“抛砖引玉”的自动化方案，适用于低频维护场景
- 若需更高频的数据修改，以及真正的持久化数据，建议配合远程数据库（MySQL/PostgreSQL）使用
