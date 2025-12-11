#!/bin/bash

#パスワード保存ファイル
DATA_FILE="restore.gpg"
TEMP_FILE="temp_restore.txt"

echo "GPGパスフレーズを入力して下さい:"

read -s GPG_PASS

if [ -f "$DATA_FILE" ]; then
	echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 -q --dry-run -d "$DATA_FILE" > /dev/null 2>&1

	if [ $? -ne 0 ]; then
		echo "wrong password"
		exit 1
	else
		echo "success"
	fi
else
	echo "データファイルを新規作成します"
	echo "今回入力したパスワードを覚えておいてください"
fi

while true; do
	echo "次の選択肢から入力してください(Add Password/Get Password/Exit):"
	read choice

	case "$choice" in
		"Add Password")

			read -p "サービス名を入力してください" service_name
			read -p "ユーザー名を入力してください" user_name
			read -p "パスワードを入力してください" password
			
			if [ -f "$DATA_FILE" ]; then
				echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 -q -d -o "$TEMP_FILE" "$DATA_FILE" 2>/dev/null
			else
				touch "$TEMP_FILE"
			fi

			echo "${service_name}:${user_name}:${password}" >> "$TEMP_FILE"

			echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 -c -o "$DATA_FILE" "$TEMP_FILE"

			rm "$TEMP_FILE"

			echo "パスワードの追加と暗号化に成功しました。"
			;;


		"Get Password")

			read -p "サービス名を入力してください:" search_service
			result=$(echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 -q -d "$DATA_FILE" | grep -a "${search_service}:" | head -n 1)

			if [ -z "$result" ]; then
				echo "そのサービスは登録されていないか、復号化に失敗しました。"
			else
				s_name=$(echo "$result" | cut -d: -f1)
				u_name=$(echo "$result" | cut -d: -f2)
				p_word=$(echo "$result" | cut -d: -f3)
				
				echo "サービス名:$s_name"
				echo "ユーザー名:$u_name"
				echo "パスワード:$p_word"
			fi
			;;

		"Exit")
			echo "Thank you!"
			unset GPG_PASS
			echo "ログアウトして終了します"
			exit 0
			;;
		*)
			echo "入力が間違えています。Add Password/Get Password/Exit　から入力してください"
			;;
	esac
done	
