
new FastClick(document.body);

$("#login_btn").click(function() {
	console.log("点击了登录按键");
	var username = $("#username").val();
	var password = $("#password").val();
	window.localStorage["username"] =username;
	window.localStorage["password"] =password;

	var isRemember = $('#isRemember:checked').val();
	if (isRemember === undefined) {
		isRemember = "false";
	}
	cordova.exec(function(data) {
		console.log("进入exec");
		data = $.parseJSON(data);
		if (data.isSuccess === true) {

		}
	}, function(err) {
	}, "CubeLogin", "login", [username, password, isRemember]);

});

var app = {
	initialize: function() {
		this.bindEvents();
	},
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	onDeviceReady: function() {
		app.receivedEvent('deviceready');
	},
	receivedEvent: function(id) {
		cordova.exec(function(data) {
			data = $.parseJSON(data);
			$("#username").val(data.username);
			$("#password").val(data.password);
			if (data.isRemember === true) {
				$("#isRemember").attr("checked", 'checked');
			}
		}, function(err) {
			alert(err);
		}, "CubeLogin", "getAccountMessage", []);
	}
};
app.initialize();