extends Node

func convert_text_to_arrow(text: String, color_str: String=""):
    var result = ""
    for character in text:
        match character:
            "U":
                result += "[img=30 color={0}]res://assets/sprite/arrow_up.png[/img]".format([color_str])
            "L":
                result += "[img=30 color={0}]res://assets/sprite/arrow_left.png[/img]".format([color_str])
            "R":
                result += "[img=30 color={0}]res://assets/sprite/arrow_right.png[/img]".format([color_str])
            "D":
                result += "[img=30 color={0}]res://assets/sprite/arrow_down.png[/img]".format([color_str])
    return result