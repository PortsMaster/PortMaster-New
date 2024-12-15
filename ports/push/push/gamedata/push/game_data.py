import os
import sys
import json
import pyxel
import const

try:
    from js import localStorage
except ImportError:
    pass

class GameData:
    def __init__(self):
        # 保存ファイルパス
        self.path = f"{pyxel.user_data_dir(const.VENDER_NAME, const.APP_NAME)}save.hz3"

        # キー
        self.key = "pyxel"
        
        if const.DEBUG_MODE:
            print("GameData保存場所: ", self.path)

        # ゲームデータ
        self.data_dict = self.get_default_data()

    def get_default_data(self) -> dict:
        return {
            "cur_level_index" : 0,
            "is_all_clear" : False,
            "level_states" : []
        }

    def save(self):
        # データ書き込み
        # データをJsonテキストにエンコード
        json_text: str = json.dumps(self.data_dict)

        # Jsonテキストを暗号化
        encrypted_data: bytearray = self.xor_encrypt_decrypt(json_text, self.key)

        if "js" in sys.modules:
            # JavaScript用
            localStorage.setItem("game_data", json_text)
        else:
            with open(self.path, "wb") as f:
                # 暗号化されたバイト配列データを指定のファイルパスに書き込み
                f.write(encrypted_data)
            
            if const.DEBUG_MODE:
                print("データを保存しました。")


    def load(self):
        # データ読み込み
        if "js" in sys.modules:
            json_text = localStorage.getItem("game_data")

            if json_text == None or json_text == "":
                # 読み込み失敗
                self.data_dict = self.get_default_data()
            else:
                self.data_dict = json.loads(json_text)
        else:
            try:
                if os.path.exists(self.path):
                    # ファイルが存在する場合
                    
                    # 暗号化されたゲームデータのバイト配列データを読み込み
                    with open(self.path, mode="rb") as f:
                        encrypted_data = f.read()

                    # 暗号化されたバイト配列データを復号化
                    decrypted_data: bytearray = self.xor_encrypt_decrypt(encrypted_data.decode(), self.key)

                    # バイトデータ配列をJsonデコード
                    data_dict = json.loads(decrypted_data)

                    if data_dict == None:
                        self.data_dict = self.get_default_data()
                    else:
                        self.data_dict = data_dict

                    if const.DEBUG_MODE:
                        print("データを読み込みました。", self.data_dict)
            except FileNotFoundError:
                if const.DEBUG_MODE:
                    print("データを存在しません。")
                
                self.data_dict = self.get_default_data()


    def xor_encrypt_decrypt(self, data, key):
        """XOR暗号化/復号化

        Args:
            data (_type_): データ
            key (_type_): 鍵

        Returns:
            _type_: 暗号化/復号化済みのデータ
        """        
        key = key.encode()  # 鍵をバイト列に
        encrypted = bytearray()
        for i, byte in enumerate(data.encode()):  # データをバイト列に
            encrypted.append(byte ^ key[i % len(key)])  # XOR演算
        return encrypted