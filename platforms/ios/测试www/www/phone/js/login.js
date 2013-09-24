new FastClick(document.body);
window.addEventListener("keydown", function(evt) {
	if (evt.keyCode === 13) {
		$("#LoginBtn").trigger("click");
	}
});
$('input').focus(function() {
	var keyword = $(this).val();
	if (keyword == "" || keyword == undefined || keyword == null) {
		$(this).next(".del_content").hide();
	} else {
		$(this).next(".del_content").css("display", "inline");
	}

});
$('#username,#password').click(function(e) {
	e.preventDefault();
	e.stopPropagation();
});

$("#username_del").click(function() {
	$(this).parent().hide();
	$("#username").val("");
});
$("#password_del").click(function() {
	$(this).parent().hide();
	$("#password").val("");
});
$("#username,#password").live("input propertychange", function() {
	var keyword = $(this).val();
	if (keyword == "" || keyword == null || keyword == undefined) {
		$(this).next(".del_content").hide();
	} else {
		$(this).next(".del_content").css("display", "inline");
	}

});
$("body").click(function() {
	$(".del_content").hide();
});

$("#LoginBtn").click(function() {
	$(this).disabled = "disabled";
	var username = $("#username").val();
	var password = $("#password").val();
	var isRemember = $('#isRemember:checked').val();

	if (isRemember === undefined) {
		isRemember = "false";
	}
	cordova.exec(function(data) {
		data = $.parseJSON(data);
		if (data.isSuccess === true) {
			$(this).removeAttr("disabled");
		}
	}, function(err) {

		err = $.parseJSON(err);
		$(this).removeAttr("disabled");
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