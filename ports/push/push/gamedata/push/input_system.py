import pyxel

class InputSystem:
    actions = {
        "submit": [
            pyxel.KEY_SPACE,
            pyxel.KEY_RETURN,
            pyxel.GAMEPAD1_BUTTON_A,
        ],
        "cancel": [
            pyxel.KEY_ESCAPE,
            pyxel.GAMEPAD1_BUTTON_B
        ]
    }

    # def add(action_id: str, key: int):
    #     if action_id not in InputSystem.actions:
    #         # 存在しないアクションIDを指定した場合
    #         InputSystem.actions[action_id] = []
    #         InputSystem.actions[action_id].append(key)
    #     else:
    #         InputSystem.actions[action_id].append(key)

    def add(action_id: str, keys: list[int]):
        if action_id not in InputSystem.actions:
            # 存在しないアクションIDを指定した場合
            InputSystem.actions[action_id] = []
            
            for key in keys:
                InputSystem.actions[action_id].append(key)
        else:
            for key in keys:
                if key not in InputSystem.actions[action_id]:
                    InputSystem.actions[action_id].append(key)

    def is_down(action_id: str) -> bool:
        if action_id not in InputSystem.actions:
            # 存在しないアクションIDを指定した場合
            return False
        
        for input_key in InputSystem.actions[action_id]:
            is_pressed = pyxel.btn(input_key)
            if is_pressed:
                return True
        return False


    def is_pressed(action_id: str, hold: int = 0, repeat: int = 0) -> bool:
        """指定したIDのキー群のどれかを押下時にTrueを返す

        Args:
            action_id (str): _description_
            hold (int, optional): _description_. Defaults to 0.
            repeat (int, optional): _description_. Defaults to 0.

        Returns:
            bool: _description_
        """        
        if action_id not in InputSystem.actions:
            # 存在しないアクションIDを指定した場合
            return False
        
        for input_key in InputSystem.actions[action_id]:
            is_pressed = pyxel.btnp(input_key, hold, repeat)
            if is_pressed:
                return True
        return False
    
            
    def is_released(action_id: str) -> bool:
        if action_id not in InputSystem.actions:
            # 存在しないアクションIDを指定した場合
            return False

        for input_key in InputSystem.actions[action_id]:
            is_released = pyxel.btnr(input_key)
            if is_released:
                return True
        return False