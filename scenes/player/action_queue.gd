extends Node
class_name Action_Queue
#links
const LINK = preload("res://scenes/player/link.gd")
var head:Link
var tail:Link
var latest:Link
var length:int = 0

func _Action_Queue(link):
	head = link
	tail = link

func _enqueue(time_passed, position, boolean_one, string, boolean_two):#enqueues node
	var link:Link = LINK.new()
	link._Link(time_passed, position, boolean_one, string, null, boolean_two)
	if not tail:
		head = link
		tail = link
	else:
		tail.next = link
		tail = link
	
	_length()
	if length > 200:
		_dequeue()

func _dequeue()->Link:#returns head
	if not head:
		return null
	var temp = head
	head = head.next
	if not head:
		tail = null
	return temp
	
func _check(time_passed)->bool:#checks if head is suppose to be played
	if not head:
		return false
	if head.time <= time_passed:
		return true
	return false

func _clear():#clears queue
	head = null
	tail = null

func rewind(height):#looks for latest valid pos
	latest = null
	_loop(head, height)
	if latest:
		head = latest
	else:
		head = tail
	return head.position

func _loop(current, height):#for rewind
	if current == null:
		return
	if current.next == null:
		return
	if current.on_floor and abs(height - current.position.y) < 4:
		latest = current;
	_loop(current.next, height)

func _length():#sets length
	length = 0
	_length_loop(head)

func _length_loop(current):
	if current == null:
		return
	length += 1
	if current.next == null:
		return
	_length_loop(current.next)
