extends Node

func convert_text_to_arrow(text: String, color_str: String="", size: int=30):
    var result = ""
    for character in text:
        match character:
            "U":
                result += "[img={0} color={1}]res://assets/sprite/arrow_up.png[/img]".format([size, color_str])
            "L":
                result += "[img={0} color={1}]res://assets/sprite/arrow_left.png[/img]".format([size, color_str])
            "R":
                result += "[img={0} color={1}]res://assets/sprite/arrow_right.png[/img]".format([size, color_str])
            "D":
                result += "[img={0} color={1}]res://assets/sprite/arrow_down.png[/img]".format([size, color_str])
    return result