$(function(){$("#mondo_answer").click(function(){var n=0;return $(this).closest("form").find("textarea").each(function(){""==$(this).val()&&(n+=1)}),4==n?($("#mondo_edit_modal .modal-body").prepend('<div class="alert alert-danger">ERROR:1つ以上入力してください</div>'),!1):void 0})});