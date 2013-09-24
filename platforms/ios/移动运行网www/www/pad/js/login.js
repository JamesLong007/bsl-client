var window_height = $(window).height();

$("body").click(function() {
	$(".del_content").hide();
	console.log("body click");
});
$('#username, #password').click(function(e) {
	if ($(this).val() !== null && $(this).val() !== "" && $(this).val !== undefined) {
		$(this).next(".del_content").css("display","inline");
	}

	e.preventDefault();
	e.stopPropagation();
});

/*$('#username, #password').blur(function() {
	console.log("input blur");
	$(this).next(".del_content").hide();
});*/

$("#username_del").click(function() {
	$(this).hide();
	$("#username").val("");
});
$("#password_del").click(function() {
	$(this).hide();
	$("#password").val("");
});
$("#username,#password").live("input propertychange", function() {
	var keyword = $(this).val();
	if (keyword == "" || keyword == null || keyword == undefined) {
		$(this).next(".del_content").hide();
	} else {
		console.log("显示");
		$(this).next(".del_content").css("display", "inline");
	}

});

$("#LoginBtn").click(function() {

	var username = $("#username").val();
	var password = $("#password").val();
	var isRemember = $('#isRemember:checked').val();
	window.localStorage["username"] =username;
	window.localStorage["password"] =password;

	/*if (username === "" || username === null) {
		showAlert("账号不能为空", null, "提示", "确定");
		return;
	} else if (password === "" || password === null) {
		showAlert("密码不能为空", null, "提示", "确定");
		return;
	} else */
	if (isRemember === undefined) {
		//alert("")
		isRemember = "false";
	}

	cordova.exec(function(data) {
		data = $.parseJSON(data);
		if (data.isSuccess === true) {
			//TODO
		}
	}, function(err) {
		err = $.parseJSON(err);
		//showAlert(err.message, null, "提示", "确定");
	}, "CubeLogin", "login", [username, password, isRemember]);

});

/*var showAlert = function(message, callback, title, buttonName) {
	navigator.notification.alert(
		message, // message

	function() {
		if (callback !== null || callback !== undefined) {
			callback();
		}
	}, // callback
	title, // title
	buttonName // buttonName
	);
};*/

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