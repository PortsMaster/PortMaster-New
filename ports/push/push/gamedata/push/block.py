import pyxel
from blocks_data import BlocksData

class Block():
    def __init__(self):
        # 画像
        self.img: pyxel.Image = None
        # 位置座標
        self.x = 0
        self.y = 0
        # オフセット位置
        self.offset_x = 0
        self.offset_y = -16
        # レイヤー
        self.layer = 0

        self.u = 0
        self.v = 0
        self.w = 16
        self.h = 32
        
        self.blocks_data: BlocksData = None
        self.uvs = []
        self.max_anim_count: int = 1

        self.anim_interval: int = 20

        # クリアカラー
        self.clear_col = 0
        
        # 管理ID
        self.id: int = -1


    def reload_block_data(self, blocks_data: dict, target_bounds_name: str, max_anim_count: int):
        if blocks_data != None:
            self.blocks_data = blocks_data

            self.img = self.blocks_data.img

            self.max_anim_count = max_anim_count

            self.uvs.clear()
            for i in range(max_anim_count):
                bounds = self.get_bounds(f"{target_bounds_name}_{i}")
                if bounds != None:
                    self.uvs.append(bounds)
            
            self.frame_count = 0
            self.anim_interval = 20
            self.current_anim_index = 0

            if len(self.uvs) > 0:
                # 初期画像設定
                self.u = self.uvs[self.current_anim_index]["x"]
                self.v = self.uvs[self.current_anim_index]["y"]


    def update(self):
        if len(self.uvs) < 1:
            return

        self.frame_count += 1

        if self.frame_count > self.anim_interval:
            self.frame_count = 0
            self.current_anim_index += 1
            if self.current_anim_index > self.max_anim_count - 1:
                self.current_anim_index = 0
            
            self.u = self.uvs[self.current_anim_index]["x"]
            self.v = self.uvs[self.current_anim_index]["y"]
    

    def draw(self):
        pyxel.blt(
            self.x + self.offset_x, self.y + self.offset_y,
            self.img,
            self.u, self.v,
            self.w, self.h,
            self.clear_col
        )


    def get_bounds(self, name: str):
        """blocks_dataからboundsデータ取得

        Args:
            name (str): _description_

        Returns:
            _type_: _description_
        """        

        if self.blocks_data == None:
            return None

        for slice in self.blocks_data.slices_json:
            if slice["name"] == name:
                return slice["keys"][0]["bounds"]
        return None