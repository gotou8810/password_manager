#!/bin/bash

#パスワード保存ファイル
DATA_FILE="restore.txt"

while true; do
	echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
	read choice

	case "$choice" in
		"Add Password")

			read -p "サービス名を入力してください" service_name
			read -p "ユーザー名を入力してください" user_name
			read -p "パスワードを入力してください" password

			echo "${service_name}:${user_name}:${password}" >> "$DATA_FILE"
			echo "パスワードの追加は成功しました。"
			;;


		"Get Password")

			read -p "サービス名を入力してください:" search_service

			if ! grep -q "^${search_service}:" "$DATA_FILE"; then
				echo "そのサービスは登録されていません。"
			else
				line=$(grep "^${search_service}:" "$DATA_FILE" | head -n 1)
				s_name=$(echo "$line"	| cut -d: -f1)
				u_name=$(echo "$line" | cut -d: -f2)
				p_word=$(echo "$line" | cut -d: -f3)
				
				echo "サービス名:$s_name"
				echo "ユーザー名:$u_name"
				echo "パスワード:$p_word"
			fi
			;;

		"Exit")
			echo "Thank you!"

			exit 0
			;;
		*)
			echo "入力が間違えています。Add Password/Get Password/Exit　から入力してください"
			;;
	esac
done	
