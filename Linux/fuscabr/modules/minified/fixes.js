/******************************************
 * FBR - "Funções úteis para o ScadaBR"
 * License: MIT
 ******************************************/
"use strict";fuscabr.fixes={preventAccidentalViewDeleting:function(){var e=document.querySelector("input[name='delete']");e.type="button",e.name="delete-disabled",e.addEventListener("click",fuscabr.fixes.deleteView)},deleteView:function(){if(window.confirm("WARNING! \nYou are about to DELETE this Graphical View! \n\nContinue?")){var e=document.querySelector("form[name='view']"),i=document.createElement("input");i.type="hidden",i.name="delete",i.value="Apagar",e.appendChild(i),e.submit()}},changePositionEditor:function(){positionEditor,positionEditor=this.positionEditor},positionEditor:function(e,i){var t=getNodeBounds($("c"+e)),n=document.getElementById(i);n.style.left=t.x+20+"px",n.style.top=t.y+10+"px"},getSettings:function(){ajaxGetJson("resources/fuscabr/conf/modules/fixes.json",function(e){fuscabr.fixes.conf=e,fuscabr.fixes.init()})},init:function(){fuscabr.fixes.conf?(fuscabr.fixes.conf.enablePreventViewDeleting&&fuscabr.fixes.preventAccidentalViewDeleting(),fuscabr.fixes.conf.enableChangePositionEditor&&fuscabr.fixes.changePositionEditor()):fuscabr.fixes.getSettings()}},fuscabr.fixes.init();
