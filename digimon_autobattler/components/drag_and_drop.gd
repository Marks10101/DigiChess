class_name DragAndDrop
extends Node

# Señales que se emitirán en diferentes momentos del arrastrar y soltar.


@export var enabled: bool = true
@export var target: Area2D

# Variables internas para gestionar el arrastre.
var starting_position: Vector2  # Posición inicial del objeto al comenzar el arrastre.
var offset := Vector2.ZERO  # Desplazamiento entre el ratón y la posición del objeto.
var dragging := false  # Indica si el objeto está siendo arrastrado.

func _ready() -> void:
	# Comprueba que se haya asignado un objetivo. Si no, lanza un error.
	assert(target, "No se ha establecido ningún objetivo para el componente DragAndDrop!")
	# Conecta la señal input_event del nodo objetivo al método _on_target_input_event.
	target.input_event.connect(_on_target_input_event.unbind(1))

func _process(_delta: float) -> void:
	# Si se está arrastrando el objeto, actualiza su posición para seguir al ratón.
	if dragging and target:
		target.global_position = target.get_global_mouse_position() + offset

func _input(event: InputEvent) -> void:
	# Cancela el arrastre si se presiona la acción "cancel_drag".
	if dragging and event.is_action_pressed("cancel_drag"):
		_cancel_dragging()
	# Finaliza el arrastre si se suelta el botón de selección.
	elif dragging and event.is_action_released("select"):
		_drop()

func _end_dragging() -> void:
	# Finaliza el estado de arrastre y reinicia configuraciones.
	dragging = false
	target.remove_from_group("dragging")  # Retira el objeto del grupo "dragging".
	target.z_index = 0  # Restablece el z_index (profundidad visual) del objeto.

func _cancel_dragging() -> void:
	# Cancela el arrastre y emite la señal correspondiente.
	_end_dragging()
	drag_canceled.emit(starting_position)  # Envía la posición inicial como argumento.

func _start_dragging() -> void:
	# Inicia el proceso de arrastre.
	dragging = true
	starting_position = target.global_position  # Guarda la posición inicial del objeto.
	target.add_to_group("dragging")  # Agrega el objeto al grupo "dragging".
	target.z_index = 99  # Aumenta el z_index para que el objeto quede al frente.
	offset = target.global_position - target.get_global_mouse_position()  # Calcula el desplazamiento inicial.
	drag_started.emit()  # Emite la señal de inicio de arrastre.

func _drop() -> void:
	# Finaliza el arrastre y emite la señal correspondiente.
	_end_dragging()
	dropped.emit(starting_position)  # Envía la posición inicial como argumento.

func _on_target_input_event(_viewport: Node, event: InputEvent) -> void:
	# Gestiona los eventos de entrada en el nodo objetivo.
	if not enabled:  # Si el sistema está deshabilitado, no hace nada.
		return

	# Comprueba si ya hay un objeto siendo arrastrado.
	var dragging_object := get_tree().get_first_node_in_group("dragging")
	if not dragging and dragging_object:  # Si hay otro objeto siendo arrastrado, no permite iniciar otro.
		return

	# Inicia el arrastre si se presiona la acción "select".
	if not dragging and event.is_action_pressed("select"):
		_start_dragging()
