$(function(){
	$("#mondo_answer").click(function(){
	    var empty = 0;
	    $(this).closest("form").find("textarea").each(function(){
		   if($(this).val()==""){empty = empty + 1} 
	    });
	    if(empty == 4){
	    $("#mondo_edit_modal .modal-body").prepend('<div class="alert alert-danger">ERROR:1つ以上入力してください</div>');
	    return false;
	    }
	});
});
