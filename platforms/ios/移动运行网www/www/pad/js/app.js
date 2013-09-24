$(function() {
	$("#LoginBtn").click(function(){
		var username = $("#username").val();
		var password = $("#password").val();
		var isRemeber = $('#isRemeber:checked').val();

		alert(username+"---"+password+"---"+isRemeber);
	});
});