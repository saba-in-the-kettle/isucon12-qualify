# ↓↓↓当日いじる↓↓↓
# アプリケーション
BUILD_DIR:=./go# ローカルマシンのMakefileからの相対パス
BIN_NAME:=isuports
SERVER_BINARY_DIR:=~/webapp/go
SERVICE_NAME:=isuports.service
# ↑↑↑ここまで↑↑↑

# colors
ESC=$(shell printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
BLUE="${ESC}[33m"

# commands
START_ECHO=echo "$(GREEN)$(BOLD)[INFO] start $@ $$s $(RESET)"

.PHONY: build
build:
	@ $(START_ECHO);\
	cd $(BUILD_DIR); \
	docker-compose up --build

.PHONY: deploy-app
deploy-app: build
	@ for s in s1; do\
		$(START_ECHO);\
		ssh $$s "sudo systemctl daemon-reload";\
		ssh $$s "sudo systemctl stop $(SERVICE_NAME)";\
		scp $(BUILD_DIR)/$(BIN_NAME) $$s:$(SERVER_BINARY_DIR);\
		ssh $$s "chmod +x  $(SERVER_BINARY_DIR)/$(BIN_NAME)";\
		ssh $$s "sudo systemctl start $(SERVICE_NAME)";\
	done

# 当日ファイル名をいじる
.PHONY: deploy-sql
deploy-sql:
	@ for s in s1 s2 s3; do\
		$(START_ECHO);\
		scp sql/init.sh $$s:~/webapp/sql/init.sh;\
		ssh $$s "chmod +x ~/webapp/sql/init.sh";\
		scp sql/init.sql $$s:~/webapp/sql/init.sql;\
		scp sql/init.sql $$s:~/webapp/sql/sqlite3-to-sql;\
		scp -r sql/admin $$s:~/webapp/sql;\
		scp -r sql/tenant $$s:~/webapp/sql;\
	done

.PHONY: deploy-config
deploy-config:
	@ for s in s1 s2 s3; do\
		$(START_ECHO);\
		cd $$s && ./deploy.sh && cd -;\
	done

.PHONY: deploy
deploy: deploy-config deploy-sql deploy-app


.PHONY: port-forward
port-forward:
	ssh -N s1 -L 19999:localhost:19999 -L 9000:localhost:9000  &
	ssh -N s2 -L 29999:localhost:19999 -L 3306:localhost:3306 &
	ssh -N s3 -L 39999:localhost:19999 &
