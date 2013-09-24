var myScroll;
function loaded() {
	myScroll = new iScroll("wrapper", { hScrollbar: false, vScrollbar: false,checkDOMChanges : true});
}
document.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
document.addEventListener('DOMContentLoaded', function() {
	setTimeout(loaded,200)
}, false);

function allowFormsInIscroll() {
	[].slice.call(document.querySelectorAll('input, select, button')).forEach(
			function(el) {
				el.addEventListener(('ontouchstart' in window) ? 'touchstart'
						: 'mousedown', function(e) {
					e.stopPropagation();

				})
			})
}

document.addEventListener('DOMContentLoaded', allowFormsInIscroll, true);




/*document.addEventListener('touchmove',function (e) {  
	myScroll.refresh();  
	e.preventDefault();  
	,bounce:false
}, false);  
*/


