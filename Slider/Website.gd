extends HTTPRequest

#var url = "https://www.google.com" #"https://opentdb.com/api.php?amount=10"
	#request("https://httpbin.org/get")
	#request("https://opentdb.com/api.php?amount=10")

var website_data = ""
var ind = 0
var website_urls = ["https://violetcloud-ai.github.io/webtest1/"]
#var website_urls = [ "https://www.google.com","https://httpbin.org/get","https://opentdb.com/api.php?amount=10"]
# Called when the node enters the scene tree for the first time.



#var _callback = JavaScriptBridge.create_callback(_on_slider_changed)
#func _ready():
	#if OS.has_feature("web"):
		#var window = JavaScriptBridge.get_interface("window")
		#window.onSliderInput = _callback # Assign Godot function to a JS window property


func _ready():
	request_completed.connect(_on_request_completed)


func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var html = body.get_string_from_utf8()
	#website_data = "" #refresh
	website_data = html
	#print("Wb 22, json:", json)
	print("Wb 23, html:", html)


func website():
	var url =  "https://violetcloud-ai.github.io/webtest1/" #website_urls[int(fmod(ind,len(website_urls)))]
	#var url = "https://httpbin.org/get"
	print("Wb 25, running: ", url)
	request(url)
	#ind += 1
	return website_data
	

func email(address="y4hong@gmail.com"):
	var subject = "Feedback".uri_encode()
	var body = "Hello, here is my feedback!".uri_encode()
	var mailto_url = "mailto:%s?subject=%s&body=%s" % [address, subject, body]
	OS.shell_open(mailto_url)
		
	
func slider(slider_ID):
	var OUT = "NA"
	if OS.has_feature("web"):
		#var val = JavaScriptBridge.eval("document.getElementById('mySlider').value")
		OUT = JavaScriptBridge.eval("document.getElementById("+slider_ID+").value")
		print("Wb 56: Slider Value: ", slider_ID, "", OUT)
	return OUT
