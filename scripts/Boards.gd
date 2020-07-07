extends ColorRect

onready var personal_boards_container := $ScrollContainer/MarginContainer/CenterContainer/VBoxContainer/PersonalBoardsContainer
onready var public_boards_container := $ScrollContainer/MarginContainer/CenterContainer/VBoxContainer/PublicBoardsContainer

onready var create_personal_board_button := $ScrollContainer/MarginContainer/CenterContainer/VBoxContainer/PersonalBoardsContainer/CreateBoard

const BOARD_CARD := preload("res://scenes/BoardCard.tscn")

func _ready():
	DataRepository.connect("board_created", self, "_on_board_created")
	DataRepository.connect("boards_loaded", self, "_on_boards_loaded")
	Events.connect("backend_response", self, "_on_backend_response")
	
	_refresh_boards()

func _refresh_boards():
	Utils.clear_children(personal_boards_container, [create_personal_board_button])
	Utils.clear_children(public_boards_container)
	
	for board in DataRepository.get_boards().values():
		var board_card = BOARD_CARD.instance()	
		
		if board.members.size() == 0:
			personal_boards_container.add_child(board_card)
		else:
			public_boards_container.add_child(board_card)	

		board_card.set_model(board)	
		board_card.connect("pressed", self, "_on_board_card_pressed", [board])

	_make_button_last_item(personal_boards_container, create_personal_board_button)

func _go_to_board(board):
	DataRepository.set_active_board(board)
	SceneUtils.request_route_change(SceneUtils.Routes.BOARD)

func _on_board_card_pressed(board : BoardModel):
	_go_to_board(board)

func _on_CreateBoard_pressed(is_public : bool):
	SceneUtils.create_input_field_dialog(SceneUtils.InputFieldDialogMode.CREATE_BOARD, DataRepository.get_draft_board(is_public))

func _on_board_created(board : BoardModel):
	_refresh_boards()
	
func _on_boards_loaded():
	_refresh_boards()
	
func _make_button_last_item(container : Node, button : Node):
	var amount = container.get_child_count()  
	if amount > 1:
		container.move_child(button, amount - 1)

#
# Backend signals
#

func _on_backend_response(action : int, is_success : bool, body):
	if not is_success:
		return
		
	match action:
		Backend.Event.GET_BOARDS:
			pass
			
		Backend.Event.CREATE_BOARD:
			pass
