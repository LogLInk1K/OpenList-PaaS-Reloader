FROM openlistteam/openlist:latest
WORKDIR /opt/openlist
USER root
EXPOSE 5244

CMD sh -c "\
    ./openlist server & PID=\$!; \
    \
    echo '⏳ 正在启动服务...'; \
    i=0; while ! wget -q --spider http://127.0.0.1:5244/api/public/settings; do \
        sleep 2; i=\$((i+1)); \
        [ \$i -ge 15 ] && echo '❌ 服务启动超时' && kill \$PID && exit 1; \
    done; \
    \
    [ -z \"\$OPENLIST_ADMIN_PASSWORD\" ] && echo '❌ 未设置密码' && exit 1; \
    \
    echo '🔑 正在登录...'; \
    TOKEN=\$(wget -qO- --post-data=\"{\\\"username\\\":\\\"admin\\\",\\\"password\\\":\\\"\$OPENLIST_ADMIN_PASSWORD\\\"}\" \
          --header='Content-Type: application/json' http://127.0.0.1:5244/api/auth/login 2>/dev/null | grep -o '\"token\":\"[^\"]*\"' | cut -d'\"' -f4); \
    \
    if [ \${#TOKEN} -gt 20 ]; then \
        echo '🚀 登录成功'; \
        for n in 1 2 3 4 5 6 7 8 9 10; do \
            BODY=\$(printenv STORAGE_JSON_\$n); \
            [ -n \"\$BODY\" ] || continue; \
            \
            echo \"\$BODY\" > /tmp/p.json; \
            if grep -q '\"mount_path\"' /tmp/p.json; then \
                printf \"📦 配置 \$n: \"; \
                wget -qO- --post-file=/tmp/p.json \
                     --header=\"Content-Type: application/json\" \
                     --header=\"Authorization: \$TOKEN\" \
                     http://127.0.0.1:5244/api/admin/storage/create 2>/dev/null | grep -o '\"message\":\"[^\"]*\"' || echo '完成'; \
            fi; \
            rm -f /tmp/p.json; \
        done; \
        echo '✅ 所有初始化任务已完成！'; \
    else \
        echo '❌ 认证失败'; kill \$PID; exit 1; \
    fi; \
    wait \$PID"
