!function(e){function t(t){for(var r,l,s=t[0],i=t[1],p=t[2],d=0,u=[];d<s.length;d++)l=s[d],a[l]&&u.push(a[l][0]),a[l]=0;for(r in i)Object.prototype.hasOwnProperty.call(i,r)&&(e[r]=i[r]);for(c&&c(t);u.length;)u.shift()();return n.push.apply(n,p||[]),o()}function o(){for(var e,t=0;t<n.length;t++){for(var o=n[t],r=!0,s=1;s<o.length;s++){var i=o[s];0!==a[i]&&(r=!1)}r&&(n.splice(t--,1),e=l(l.s=o[0]))}return e}var r={},a={interactiveWindow:0},n=[];function l(t){if(r[t])return r[t].exports;var o=r[t]={i:t,l:!1,exports:{}};return e[t].call(o.exports,o,o.exports,l),o.l=!0,function(e){if(e.exports&&!e.exports.__esModule&&void 0===e.exports.default){if(e.exports.headers&&e.exports.headers.common&&e.exports.headers.common.Accept&&e.exports.adapter&&e.exports.transformRequest&&e.exports.transformResponse)return;e.exports.default=e.exports}}(o),o.exports}l.e=function(e){var t=[],o=a[e];if(0!==o)if(o)t.push(o[2]);else{var r=new Promise((function(t,r){o=a[e]=[t,r]}));t.push(o[2]=r);var n,s=document.createElement("script");s.charset="utf-8",s.timeout=120,l.nc&&s.setAttribute("nonce",l.nc),s.src=function(e){return l.p+""+({"vendors~dataresource~geojson~modeldebug~nteract_transforms~nteract_transforms_vsdom":"vendors~dataresource~geojson~modeldebug~nteract_transforms~nteract_transforms_vsdom",modeldebug:"modeldebug",nteract_transforms_vsdom:"nteract_transforms_vsdom","vendors~dataresource~vega":"vendors~dataresource~vega","vendors~dataresource":"vendors~dataresource","vendors~geojson":"vendors~geojson","vendors~nteract_transforms":"vendors~nteract_transforms","vendors~vega":"vendors~vega",vega:"vega","vendors~plotly":"vendors~plotly"}[e]||e)+".bundle.js"}(e);var i=new Error;n=function(t){s.onerror=s.onload=null,clearTimeout(p);var o=a[e];if(0!==o){if(o){var r=t&&("load"===t.type?"missing":t.type),n=t&&t.target&&t.target.src;i.message="Loading chunk "+e+" failed.\n("+r+": "+n+")",i.name="ChunkLoadError",i.type=r,i.request=n,o[1](i)}a[e]=void 0}};var p=setTimeout((function(){n({type:"timeout",target:s})}),12e4);s.onerror=s.onload=n,document.head.appendChild(s)}return Promise.all(t)},l.m=e,l.c=r,l.d=function(e,t,o){l.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:o})},l.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},l.t=function(e,t){if(1&t&&(e=l(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var o=Object.create(null);if(l.r(o),Object.defineProperty(o,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var r in e)l.d(o,r,function(t){return e[t]}.bind(null,r));return o},l.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return l.d(t,"a",t),t},l.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},l.p="",l.oe=function(e){throw console.error(e),e};var s=window.webpackJsonp=window.webpackJsonp||[],i=s.push.bind(s);s.push=t,s=s.slice();for(var p=0;p<s.length;p++)t(s[p]);var c=i;n.push([7,"monaco","commons"]),o()}({"+oPt":function(e,t,o){(t=e.exports=o("I1BE")(!1)).i(o("9RTN"),""),t.push([e.i,"/* Import common styles and then override them below */\n.toolbar-menu-bar-child {\n  background: var(--override-background, var(--vscode-editor-background));\n  z-index: 10;\n}\n#main-panel-content {\n  grid-area: content;\n  max-height: 100%;\n  overflow-x: hidden;\n  overflow-y: auto;\n}\n.messages-result-container {\n  width: 100%;\n}\n.messages-result-container pre {\n  white-space: pre-wrap;\n  font-family: monospace;\n  margin: 0px;\n  word-break: break-all;\n}\n.cell-wrapper {\n  margin: 0px;\n  padding: 0px;\n  display: block;\n}\n.cell-result-container {\n  margin: 0px;\n  display: grid;\n  grid-auto-columns: minmax(0, 1fr);\n}\n.cell-outer {\n  display: grid;\n  grid-template-columns: auto minmax(0, 1fr) 8px;\n  grid-column-gap: 3px;\n  width: 100%;\n}\n.cell-output {\n  margin: 0px;\n  width: 100%;\n  overflow-x: scroll;\n  background: transparent;\n}\n.cell-output > div {\n  background: var(--override-widget-background, var(--vscode-notifications-background));\n}\nxmp {\n  margin: 0px;\n}\n.cell-input {\n  margin: 0;\n}\n.markdown-cell-output {\n  width: 100%;\n  overflow-x: scroll;\n}\n.cell-output-text {\n  white-space: pre-wrap;\n  word-break: break-all;\n  overflow-x: hidden;\n}\n",""])},7:function(e,t,o){o("201c"),e.exports=o("EMpZ")},EMpZ:function(e,t,o){"use strict";o.r(t);o("HWNH"),o("usN3");var r=o("q1tI"),a=o("i8i4"),n=o("/MKj"),l=o("JyUj"),s=o("eyGK"),i=o("Aohs"),p=o("mrSG"),c=o("yXML"),d=o("KoO9"),u=o("jss3"),h=o("d+9d"),m=o("KNyV"),b=o("qUK1"),f=o("uunU"),g=o("btyL"),v=o("kobn"),S=o("cwXv"),C=o("t4XM"),y=(o("KbE7"),o("aUsF")),k=o("2g1K"),E=o("2rLJ"),O=o("PX74"),T=function(e){function t(t){return e.call(this,t)||this}return Object(p.c)(t,e),t.prototype.render=function(){var e="collapse-input-svg "+(this.props.open?" collapse-input-svg-rotate":"")+" collapse-input-svg-"+this.props.theme,t="collapse-input remove-style "+(this.props.visible?"":" invisible"),o=this.props.open?Object(S.a)("DataScience.collapseSingle","Collapse"):Object(S.a)("DataScience.expandSingle","Expand"),a=this.props.open?"true":"false";return r.createElement("button",{className:t,title:o,onClick:this.props.onClick,"aria-expanded":a},r.createElement("svg",{version:"1.1",baseProfile:"full",width:"8px",height:"11px"},r.createElement("polygon",{points:"0,0 0,10 5,5",className:e,fill:"black"})),this.props.label&&r.createElement("label",{className:"collapseInputLabel"},this.props.label))},t}(r.Component),M=o("QZoQ"),V=o("M7O9"),x=function(){function e(){this.historyStack=[]}return e.prototype.completeUp=function(e){if(this.historyStack.length>0){void 0===this.up&&(this.up=0);var t=this.up<this.historyStack.length?this.historyStack[this.up]:e;return this.adjustCursors(this.up),t}return e},e.prototype.completeDown=function(e){if(this.historyStack.length>0&&void 0!==this.down){var t=this.historyStack[this.down];return this.adjustCursors(this.down),t}return e},e.prototype.add=function(e,t){this.historyStack=0===this.last&&this.historyStack.length>0&&this.historyStack[this.last]===e?this.historyStack:Object(p.f)([e],this.historyStack),t?this.reset():0===this.last?(this.up=void 0,this.down=void 0):this.last&&(this.up=this.last+1,this.down=this.last-1)},e.prototype.reset=function(){this.up=void 0,this.down=void 0},e.prototype.adjustCursors=function(e){this.last=e,this.historyStack.length>1&&(e<this.historyStack.length?this.up=e+1:(this.up=this.historyStack.length,e=this.historyStack.length-1),this.down=e>0?e-1:void 0)},e}(),I=o("n9S5"),j=function(e){function t(t){var o=e.call(this,t)||this;return o.codeRef=r.createRef(),o.wrapperRef=r.createRef(),o.toggleInputBlock=function(){var e=o.getCell().id;o.props.toggleInputBlock(e)},o.getCell=function(){return o.props.cellVM.cell},o.isCodeCell=function(){return"code"===o.props.cellVM.cell.data.cell_type},o.renderNormalToolbar=function(){var e=o.getCell(),t=e.id,a=!e||!e.file||e.file===c.a.EmptyFileName;return r.createElement("div",{className:"cell-toolbar",key:0},r.createElement(v.a,{baseTheme:o.props.baseTheme,onClick:function(){return o.props.gatherCell(t)},hidden:!o.props.settings.enableGather,tooltip:Object(S.a)("DataScience.gatherCodeTooltip","Gather code")},r.createElement(g.a,{baseTheme:o.props.baseTheme,class:"image-button-image",image:g.b.GatherCode})),r.createElement(v.a,{baseTheme:o.props.baseTheme,onClick:function(){return o.props.gotoCell(t)},tooltip:Object(S.a)("DataScience.gotoCodeButtonTooltip","Go to code"),hidden:a},r.createElement(g.a,{baseTheme:o.props.baseTheme,class:"image-button-image",image:g.b.GoToSourceCode})),r.createElement(v.a,{baseTheme:o.props.baseTheme,onClick:function(){return o.props.copyCellCode(t)},tooltip:Object(S.a)("DataScience.copyBackToSourceButtonTooltip","Paste code into file"),hidden:!a},r.createElement(g.a,{baseTheme:o.props.baseTheme,class:"image-button-image",image:g.b.Copy})),r.createElement(v.a,{baseTheme:o.props.baseTheme,onClick:function(){return o.props.deleteCell(t)},tooltip:Object(S.a)("DataScience.deleteButtonTooltip","Remove Cell")},r.createElement(g.a,{baseTheme:o.props.baseTheme,class:"image-button-image",image:g.b.Cancel})))},o.onMouseClick=function(e){e.stopPropagation(),o.props.clickCell(o.props.cellVM.cell.id)},o.renderControls=function(){var e=o.props.cellVM.cell.state===k.a.init||o.props.cellVM.cell.state===k.a.executing,t=o.props.cellVM.inputBlockCollapseNeeded&&o.props.cellVM.inputBlockShow&&!o.props.cellVM.editable&&o.isCodeCell(),a=o.props.cellVM&&o.props.cellVM.cell&&o.props.cellVM.cell.data&&o.props.cellVM.cell.data.execution_count?o.props.cellVM.cell.data.execution_count.toString():"-",n=o.props.cellVM.cell.id===c.a.EditCellId,l=n?null:o.renderNormalToolbar();return r.createElement("div",{className:"controls-div"},r.createElement(M.a,{isBusy:e,count:n&&o.props.editExecutionCount?o.props.editExecutionCount:a,visible:o.isCodeCell()}),r.createElement(T,{theme:o.props.baseTheme,visible:t,open:o.props.cellVM.inputBlockOpen,onClick:o.toggleInputBlock,tooltip:Object(S.a)("DataScience.collapseInputTooltip","Collapse input block")}),l)},o.renderInput=function(){return o.isCodeCell()?r.createElement(E.a,{cellVM:o.props.cellVM,editorOptions:o.props.editorOptions,history:o.inputHistory,codeTheme:o.props.codeTheme,onCodeChange:o.onCodeChange,onCodeCreated:o.onCodeCreated,unfocused:o.onUnfocused,testMode:!!o.props.testMode,showWatermark:o.props.showWatermark,ref:o.codeRef,monacoTheme:o.props.monacoTheme,openLink:o.openLink,editorMeasureClassName:o.props.editorMeasureClassName,keyDown:o.isEditCell()?o.onEditCellKeyDown:void 0,showLineNumbers:o.props.cellVM.showLineNumbers,font:o.props.font,disableUndoStack:o.props.cellVM.cell.id!==c.a.EditCellId,codeVersion:o.props.cellVM.codeVersion?o.props.cellVM.codeVersion:0,focusPending:o.props.focusPending}):null},o.onUnfocused=function(){o.props.unfocus(o.getCell().id)},o.onCodeChange=function(e){o.props.editCell(o.getCell().id,e)},o.onCodeCreated=function(e,t,r,a){o.props.codeCreated(r,a)},o.hasOutput=function(){return o.getCell().state===k.a.finished||o.getCell().state===k.a.error||o.getCell().state===k.a.executing},o.getCodeCell=function(){return o.props.cellVM.cell.data},o.onKeyDown=function(e){if(o.getCell().id===c.a.EditCellId){var t={code:e.key,shiftKey:e.shiftKey,ctrlKey:e.ctrlKey,metaKey:e.metaKey,altKey:e.altKey,target:e.target,stopPropagation:function(){return e.stopPropagation()},preventDefault:function(){return e.preventDefault()}};o.onEditCellKeyDown(c.a.EditCellId,t)}},o.onEditCellKeyDown=function(e,t){"Tab"===t.code&&t.shiftKey?o.editCellShiftTab(t):"Enter"===t.code&&t.shiftKey?o.editCellSubmit(t):"NumpadEnter"===t.code&&t.shiftKey?o.editCellSubmit(t):"KeyU"===t.code&&t.ctrlKey&&t.editorInfo&&!t.editorInfo.isSuggesting?(t.editorInfo.clear(),t.stopPropagation(),t.preventDefault()):"Escape"===t.code&&t.editorInfo&&!t.editorInfo.isSuggesting&&(t.editorInfo.clear(),t.stopPropagation(),t.preventDefault())},o.editCellShiftTab=function(e){var t=document.activeElement;if(null!==t&&e.editorInfo&&!e.editorInfo.isSuggesting){var r=o.findTabStop(1,t);r&&(e.stopPropagation(),e.preventDefault(),r.focus())}},o.openLink=function(e){o.props.linkClick(e.toString())},o.state={showingMarkdownEditor:!1},t.cellVM.cell.id===c.a.EditCellId&&(o.inputHistory=new x),o}return Object(p.c)(t,e),t.prototype.render=function(){return"messages"===this.props.cellVM.cell.data.cell_type?r.createElement(V.a,{messages:this.props.cellVM.cell.data.messages}):this.renderNormalCell()},t.prototype.componentDidUpdate=function(e){!this.props.cellVM.selected||e.cellVM.selected||this.props.cellVM.focused||this.giveFocus(),this.props.cellVM.scrollCount!==e.cellVM.scrollCount&&this.scrollAndFlash()},t.prototype.shouldComponentUpdate=function(e){return!y(this.props,e)},t.prototype.scrollAndFlash=function(){var e=this;this.wrapperRef&&this.wrapperRef.current&&(this.wrapperRef.current.scrollIntoView&&this.wrapperRef.current.scrollIntoView({behavior:"auto",block:"nearest",inline:"nearest"}),this.wrapperRef.current.classList.add("flash"),setTimeout((function(){e.wrapperRef.current&&e.wrapperRef.current.classList.remove("flash")}),1e3))},t.prototype.giveFocus=function(){this.wrapperRef&&this.wrapperRef.current&&(this.wrapperRef.current.contains(document.activeElement)||this.wrapperRef.current.focus(),this.wrapperRef.current.scrollIntoView&&this.wrapperRef.current.scrollIntoView({behavior:"auto",block:"nearest",inline:"nearest"}))},t.prototype.renderNormalCell=function(){var e=this.props.settings.showCellInputCode||this.props.cellVM.directInput||this.props.cellVM.editable||this.shouldRenderResults(),t=this.props.cellVM.editable?"cell-outer-editable":"cell-outer",o=this.props.cellVM.editable?"cell-wrapper":"cell-wrapper cell-wrapper-noneditable",a=!!this.props.settings.themeMatplotlibPlots;return e?r.createElement("div",{className:o,role:this.props.role,ref:this.wrapperRef,tabIndex:0,onKeyDown:this.onKeyDown,onClick:this.onMouseClick},r.createElement("div",{className:t},this.renderControls(),r.createElement("div",{className:"content-div"},r.createElement("div",{className:"cell-result-container"},this.renderInput(),r.createElement("div",null,r.createElement(O.a,{cellVM:this.props.cellVM,baseTheme:this.props.baseTheme,expandImage:this.props.showPlot,maxTextSize:this.props.maxTextSize,themeMatplotlibPlots:a,widgetFailed:this.props.widgetFailed})))))):null},t.prototype.isEditCell=function(){return this.getCell().id===c.a.EditCellId},t.prototype.shouldRenderResults=function(){return this.isCodeCell()&&this.hasOutput()&&this.getCodeCell().outputs&&this.getCodeCell().outputs.length>0&&!this.props.cellVM.hideOutput},t.prototype.editCellSubmit=function(e){if(e.editorInfo&&e.editorInfo.contents){e.stopPropagation(),e.preventDefault();for(var t=e.editorInfo.contents.length-1;t>=0&&"\n"===e.editorInfo.contents[t];)t-=1;var o=e.editorInfo.contents.slice(0,t+1);this.inputHistory&&this.inputHistory.add(o,e.editorInfo.isDirty),e.editorInfo.clear(),this.props.submitInput(o,this.props.cellVM.cell.id)}},t.prototype.findTabStop=function(e,t){if(t){var o=document.querySelectorAll("input, button, select, textarea, a[href]");if(o){var r=Array.prototype.filter.call(o,(function(e){return e.tabIndex>=0})),a=r.indexOf(t);return e>=0?r[a+1]||r[0]:r[a-1]||r[0]}}},t}(r.Component),w=Object(n.b)(null,I.a)(j);o("Zytl");function D(e){return Object(p.a)(Object(p.a)({},e.main),{variableState:e.variables})}var R=function(e){function t(t){var o=e.call(this,t)||this;return o.mainPanelRef=r.createRef(),o.contentPanelRef=r.createRef(),o.renderCount=0,o.internalScrollCount=0,o.footerPanelClick=function(e){o.props.focusInput()},o.getInputExecutionCount=function(){return o.props.currentExecutionCount+1},o.getContentProps=function(e){return{baseTheme:e,cellVMs:o.props.cellVMs,testMode:o.props.testMode,codeTheme:o.props.codeTheme,submittedText:o.props.submittedText,settings:o.props.settings,skipNextScroll:!!o.props.skipNextScroll,editable:!1,renderCell:o.renderCell,scrollToBottom:o.scrollDiv,scrollBeyondLastLine:!!o.props.settings&&o.props.settings.extraSettings.editor.scrollBeyondLastLine}},o.getVariableProps=function(e){return{variables:o.props.variableState.variables,debugging:o.props.debugging,busy:o.props.busy,showDataExplorer:o.props.showDataViewer,skipDefault:o.props.skipDefault,testMode:o.props.testMode,closeVariableExplorer:o.props.toggleVariableExplorer,baseTheme:e,pageIn:o.pageInVariableData,fontSize:o.props.font.size,executionCount:o.props.currentExecutionCount}},o.pageInVariableData=function(e,t){o.props.getVariableData(o.props.currentExecutionCount,e,t)},o.renderCell=function(e,t,a){return o.props.settings&&o.props.editorOptions?r.createElement("div",{key:e.cell.id,id:e.cell.id,ref:a},r.createElement(f.a,null,r.createElement(w,{role:"listitem",editorOptions:o.props.editorOptions,maxTextSize:o.props.settings.maxOutputSize,autoFocus:!1,testMode:o.props.testMode,cellVM:e,baseTheme:o.props.baseTheme,codeTheme:o.props.codeTheme,showWatermark:e.cell.id===c.a.EditCellId,editExecutionCount:o.getInputExecutionCount().toString(),monacoTheme:o.props.monacoTheme,font:o.props.font,settings:o.props.settings,focusPending:o.props.focusPending}))):null},o.scrollDiv=function(e){o.props.isAtBottom&&(o.internalScrollCount+=1,e&&e.scrollIntoView&&e.scrollIntoView({behavior:"auto",block:"nearest",inline:"nearest"}))},o.handleScroll=function(e){if(o.internalScrollCount>0)o.internalScrollCount-=1;else if(o.contentPanelRef.current){var t=o.contentPanelRef.current.computeIsAtBottom(e.currentTarget);o.props.scroll(t)}},o.linkClick=function(e){Object(h.a)(e,o.props.linkClick)},o}return Object(p.c)(t,e),t.prototype.componentDidMount=function(){document.addEventListener("click",this.linkClick,!0),this.props.editorLoaded()},t.prototype.componentWillUnmount=function(){document.removeEventListener("click",this.linkClick),this.props.editorUnmounted()},t.prototype.render=function(){var e={fontSize:this.props.font.size,fontFamily:this.props.font.family},t=this.props.busy&&!this.props.testMode?r.createElement(C.a,null):void 0;return this.props.testMode&&(this.renderCount=this.renderCount+1),r.createElement("div",{id:"main-panel",ref:this.mainPanelRef,role:"Main",style:e},r.createElement("div",{className:"styleSetter"},r.createElement("style",null,(this.props.rootCss?this.props.rootCss:"")+"\n"+Object(d.a)(this.props.settings))),r.createElement("header",{id:"main-panel-toolbar"},this.renderToolbarPanel(),t),r.createElement("section",{id:"main-panel-variable","aria-label":Object(S.a)("DataScience.collapseVariableExplorerLabel","Variables")},this.renderVariablePanel(this.props.baseTheme)),r.createElement("main",{id:"main-panel-content",onScroll:this.handleScroll},this.renderContentPanel(this.props.baseTheme)),r.createElement("section",{id:"main-panel-footer",onClick:this.footerPanelClick,"aria-label":Object(S.a)("DataScience.editSection","Input new cells here")},this.renderFooterPanel(this.props.baseTheme)))},t.prototype.renderToolbarPanel=function(){var e=this.props.variableState.visible?Object(S.a)("DataScience.collapseVariableExplorerTooltip","Hide variables active in jupyter kernel"):Object(S.a)("DataScience.expandVariableExplorerTooltip","Show variables active in jupyter kernel");return r.createElement("div",{id:"toolbar-panel"},r.createElement("div",{className:"toolbar-menu-bar"},r.createElement("div",{className:"toolbar-menu-bar-child"},r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.deleteAllCells,tooltip:Object(S.a)("DataScience.clearAll","Remove all cells")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.Cancel})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.redo,disabled:0===this.props.redoStack.length,tooltip:Object(S.a)("DataScience.redo","Redo")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.Redo})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.undo,disabled:0===this.props.undoStack.length,tooltip:Object(S.a)("DataScience.undo","Undo")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.Undo})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.interruptKernel,disabled:this.props.busy,tooltip:Object(S.a)("DataScience.interruptKernel","Interrupt IPython kernel")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.Interrupt})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.restartKernel,disabled:this.props.busy,tooltip:Object(S.a)("DataScience.restartServer","Restart IPython kernel")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.Restart})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.toggleVariableExplorer,tooltip:e},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.VariableExplorer})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.export,disabled:0===this.props.cellVMs.length||this.props.busy,tooltip:Object(S.a)("DataScience.export","Export as Jupyter notebook")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.SaveAs})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.expandAll,disabled:0===this.props.cellVMs.length,tooltip:Object(S.a)("DataScience.expandAll","Expand all cell inputs")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.ExpandAll})),r.createElement(v.a,{baseTheme:this.props.baseTheme,onClick:this.props.collapseAll,disabled:0===this.props.cellVMs.length,tooltip:Object(S.a)("DataScience.collapseAll","Collapse all cell inputs")},r.createElement(g.a,{baseTheme:this.props.baseTheme,class:"image-button-image",image:g.b.CollapseAll}))),r.createElement(m.a,{baseTheme:this.props.baseTheme,font:this.props.font,kernel:this.props.kernel,selectServer:this.props.selectServer,selectKernel:this.props.selectKernel})))},t.prototype.renderVariablePanel=function(e){if(this.props.variableState.visible){var t=this.getVariableProps(e);return r.createElement(b.a,Object(p.a)({},t))}return null},t.prototype.renderContentPanel=function(e){if(!this.props.monacoReady&&!this.props.testMode)return null;var t=this.getContentProps(e);return r.createElement(u.a,Object(p.a)({},t,{ref:this.contentPanelRef}))},t.prototype.renderFooterPanel=function(e){if(!(this.props.monacoReady&&this.props.editCellVM&&this.props.settings&&this.props.editorOptions&&this.props.settings.allowInput))return null;var t=this.props.settings.maxOutputSize,o=t&&t<1e4&&t>0?t:void 0,a=this.getInputExecutionCount(),n=this.props.settings.colorizeInputBox?"edit-panel-colorized":"edit-panel";return r.createElement("div",{className:n},r.createElement(f.a,null,r.createElement(w,{role:"form",editorOptions:this.props.editorOptions,maxTextSize:o,autoFocus:document.hasFocus(),testMode:this.props.testMode,cellVM:this.props.editCellVM,baseTheme:e,codeTheme:this.props.codeTheme,showWatermark:!0,editExecutionCount:a.toString(),monacoTheme:this.props.monacoTheme,font:this.props.font,settings:this.props.settings,focusPending:this.props.focusPending})))},t}(r.Component);var P,L=o("TMpg"),_=o("XHnH"),A=o("y18Z"),N=o("Ost8"),B=o("EWE8"),K=o("Z/LF"),U=o("pm+A"),F=o("p1gK"),G=o("QLg1"),W=o("Ezry"),z=o("9BvU");!function(e){function t(e,t){return!e.testMode||"messages"!==t.data.cell_type}function o(e,t,o,r){if("code"===e.cell.data.cell_type){if(e.inputBlockShow===o&&e.inputBlockOpen===r)return e;var a=Object(p.a)({},e);if(e.inputBlockShow!==o&&(a.inputBlockShow=!!o),e.inputBlockOpen!==r&&e.inputBlockCollapseNeeded&&e.inputBlockShow){var n=function(e,t){var o=Object(G.f)(e,t);return Object(F.e)(o)}(e,t);n.includes("\n")?r?(a.inputBlockOpen=!0,a.inputBlockText=n):(n.length>0&&(n=(n=(n=n.split("\n",1)[0]).slice(0,255)).concat("...")),a.inputBlockOpen=!1,a.inputBlockText=n):(a.inputBlockCollapseNeeded=!1,a.inputBlockOpen=!0,a.inputBlockText=n)}return a}return e}function r(e,t){var r,a=Object(G.c)(e,t.settings,!1,t.debugging),n=!!t.settings&&t.settings.showCellInputCode,l=!(null===(r=t.settings)||void 0===r?void 0:r.collapseCellInputCodeByDefault);return(a=o(a,t.settings,n,l)).hasBeenRun=!0,a}e.alterCellVM=o,e.prepareCellVM=r,e.startCell=function(e){if(t(e.prevState,e.payload.data)){var o=z.a.updateOrAdd(e,r);if(o.cellVMs.length>e.prevState.cellVMs.length&&e.payload.data.id!==c.a.EditCellId){var a=o.cellVMs[o.cellVMs.length-1];Object(W.d)(e,_.b.UpdateModel,{source:"user",kind:"add",oldDirty:e.prevState.dirty,newDirty:!0,cell:a.cell,fullText:Object(G.f)(a,o.settings),currentText:a.inputBlockText})}return o}return e.prevState},e.updateCell=function(e){return t(e.prevState,e.payload.data)?z.a.updateOrAdd(e,r):e.prevState},e.finishCell=function(e){return t(e.prevState,e.payload.data)?z.a.updateOrAdd(e,r):e.prevState},e.deleteAllCells=function(e){return Object(W.d)(e,_.b.DeleteAllCells),Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:[],undoStack:z.a.pushStack(e.prevState.undoStack,e.prevState.cellVMs)})},e.deleteCell=function(e){var t=e.prevState.cellVMs.findIndex((function(t){return t.cell.id===e.payload.data.cellId}));if(t>=0&&e.payload.data.cellId){Object(W.d)(e,_.b.UpdateModel,{source:"user",kind:"remove",index:t,oldDirty:e.prevState.dirty,newDirty:!0,cell:e.prevState.cellVMs[t].cell});var o=e.prevState.cellVMs.filter((function(e,o){return o!==t}));return Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:o,undoStack:z.a.pushStack(e.prevState.undoStack,e.prevState.cellVMs)})}return e.prevState},e.unmount=function(e){return Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:[],undoStack:[],redoStack:[],editCellVM:void 0})}}(P||(P={}));var H,q,J=o("Ja+E");(q=H||(H={})).expandAll=function(e){var t;if(null===(t=e.prevState.settings)||void 0===t?void 0:t.showCellInputCode){var o=e.prevState.cellVMs.map((function(t){return P.alterCellVM(Object(p.a)({},t),e.prevState.settings,!0,!0)}));return Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:o})}return e.prevState},q.collapseAll=function(e){var t;if(null===(t=e.prevState.settings)||void 0===t?void 0:t.showCellInputCode){var o=e.prevState.cellVMs.map((function(t){return P.alterCellVM(Object(p.a)({},t),e.prevState.settings,!0,!1)}));return Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:o})}return e.prevState},q.toggleInputBlock=function(e){if(e.payload.data.cellId){var t=Object(p.f)(e.prevState.cellVMs),o=e.prevState.cellVMs.findIndex((function(t){return t.cell.id===e.payload.data.cellId})),r=e.prevState.cellVMs[o];return t[o]=P.alterCellVM(Object(p.a)({},r),e.prevState.settings,!0,!r.inputBlockOpen),Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:t})}return e.prevState},q.updateSettings=function(e){var t,o=JSON.parse(e.payload.data),r=Object(J.a)(o),a=o.extraSettings?o.extraSettings.editor.fontFamily:e.prevState.font.family,n=o.extraSettings?o.extraSettings.editor.fontSize:e.prevState.font.size;if(o&&o.extraSettings&&o.extraSettings.theme!==e.prevState.vscodeThemeName){var l=z.a.computeKnownDark(o);Object(W.d)(e,A.a.GetCssRequest,{isDark:l}),Object(W.d)(e,A.a.GetMonacoThemeRequest,{isDark:l})}var s=e.prevState.cellVMs;return o.showCellInputCode!==(null===(t=e.prevState.settings)||void 0===t?void 0:t.showCellInputCode)&&(s=e.prevState.cellVMs.map((function(e){return P.alterCellVM(e,o,o.showCellInputCode,!o.collapseCellInputCodeByDefault)}))),Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:s,settings:o,editorOptions:r,font:{size:n,family:a}})},q.scrollToCell=function(e){var t=e.prevState.cellVMs.findIndex((function(t){return t.cell.id===e.payload.data.id}));if(t>=0){var o=Object(p.f)(e.prevState.cellVMs);return o[t]=Object(p.a)(Object(p.a)({},o[t]),{scrollCount:o[t].scrollCount+1}),Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:o})}return e.prevState},q.scrolled=function(e){return Object(p.a)(Object(p.a)({},e.prevState),{isAtBottom:e.payload.data.isAtBottom})},q.clickCell=function(e){return e.payload.data.cellId===c.a.EditCellId&&e.prevState.editCellVM&&!e.prevState.editCellVM.focused?Object(p.a)(Object(p.a)({},e.prevState),{editCellVM:Object(p.a)(Object(p.a)({},e.prevState.editCellVM),{focused:!0})}):e.prevState.editCellVM?Object(p.a)(Object(p.a)({},e.prevState),{editCellVM:Object(p.a)(Object(p.a)({},e.prevState.editCellVM),{focused:!1})}):e.prevState},q.unfocusCell=function(e){return e.payload.data.cellId===c.a.EditCellId&&e.prevState.editCellVM&&e.prevState.editCellVM.focused?Object(p.a)(Object(p.a)({},e.prevState),{editCellVM:Object(p.a)(Object(p.a)({},e.prevState.editCellVM),{focused:!1})}):e.prevState};var Z,X,Y,Q=o("xk4V"),$=o("PZUy"),ee=o("kYDi"),te=o("BkRI");(X=Z||(Z={})).undo=function(e){if(e.prevState.undoStack.length>0){var t=e.prevState.undoStack[e.prevState.undoStack.length-1],o=e.prevState.undoStack.slice(0,e.prevState.undoStack.length-1),r=z.a.pushStack(e.prevState.redoStack,e.prevState.cellVMs);return Object(W.d)(e,_.b.Undo),Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:t,undoStack:o,redoStack:r,skipNextScroll:!0})}return e.prevState},X.redo=function(e){if(e.prevState.redoStack.length>0){var t=e.prevState.redoStack[e.prevState.redoStack.length-1],o=e.prevState.redoStack.slice(0,e.prevState.redoStack.length-1),r=z.a.pushStack(e.prevState.undoStack,e.prevState.cellVMs);return Object(W.d)(e,_.b.Redo),Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:t,undoStack:r,redoStack:o,skipNextScroll:!0})}return e.prevState},X.startDebugging=function(e){return Object(p.a)(Object(p.a)({},e.prevState),{debugging:!0})},X.stopDebugging=function(e){return Object(p.a)(Object(p.a)({},e.prevState),{debugging:!1})},X.submitInput=function(e){var t=new $.a(e.prevState.settings);if(t.stripFirstMarker(e.payload.data.code).length>0&&e.prevState.editCellVM){var o=te(e.prevState.editCellVM);o.cell.state=k.a.executing,o.cell.data.source=e.payload.data.code;var r=e.payload.data.code.splitLines({trim:!1}),a=r[0];t.isMarkdown(a)?(o.cell.data=Object(ee.a)(o.cell.data,"markdown"),o.cell.data.source=Object(F.d)(r),o.cell.state=k.a.finished):"markdown"===o.cell.data.cell_type&&(o.cell.state=k.a.finished),o=Object(G.c)(o.cell,e.prevState.settings,!1,!1);var n=!!e.prevState.settings&&e.prevState.settings.collapseCellInputCodeByDefault;return(o=P.alterCellVM(o,e.prevState.settings,!0,!n)).useQuickEdit=!1,o.cell.id=Q(),o.directInput=!0,o.cell.state!==k.a.finished&&Object(W.d)(e,_.b.SubmitNewCell,{code:e.payload.data.code,id:o.cell.id}),Object(p.a)(Object(p.a)({},e.prevState),{cellVMs:Object(p.f)(e.prevState.cellVMs,[o]),undoStack:z.a.pushStack(e.prevState.undoStack,e.prevState.cellVMs),skipNextScroll:!1,submittedText:!0})}return e.prevState};var oe=((Y={})[U.a.RESTART_KERNEL]=B.a.restartKernel,Y[U.a.INTERRUPT_KERNEL]=B.a.interruptKernel,Y[_.b.SelectKernel]=B.a.selectKernel,Y[U.a.SELECT_SERVER]=B.a.selectJupyterURI,Y[U.a.OPEN_SETTINGS]=N.a.openSettings,Y[U.a.EXPORT]=K.a.exportCells,Y[U.a.SAVE]=K.a.save,Y[U.a.SHOW_DATA_VIEWER]=K.a.showDataViewer,Y[U.a.DELETE_CELL]=P.deleteCell,Y[_.b.ShowPlot]=K.a.showPlot,Y[U.a.LINK_CLICK]=K.a.linkClick,Y[U.a.GOTO_CELL]=K.a.gotoCell,Y[U.a.TOGGLE_INPUT_BLOCK]=H.toggleInputBlock,Y[U.a.COPY_CELL_CODE]=K.a.copyCellCode,Y[U.a.GATHER_CELL]=K.a.gather,Y[U.a.EDIT_CELL]=K.a.editCell,Y[U.a.SUBMIT_INPUT]=Z.submitInput,Y[_.b.ExpandAll]=H.expandAll,Y[U.a.EDITOR_LOADED]=K.a.started,Y[U.a.SCROLL]=H.scrolled,Y[U.a.CLICK_CELL]=H.clickCell,Y[U.a.UNFOCUS_CELL]=H.unfocusCell,Y[U.a.UNMOUNT]=P.unmount,Y[U.a.FOCUS_INPUT]=N.a.focusInput,Y[U.a.LOAD_IPYWIDGET_CLASS_SUCCESS]=N.a.handleLoadIPyWidgetClassSuccess,Y[U.a.LOAD_IPYWIDGET_CLASS_FAILURE]=N.a.handleLoadIPyWidgetClassFailure,Y[U.a.IPYWIDGET_WIDGET_VERSION_NOT_SUPPORTED]=N.a.notifyAboutUnsupportedWidgetVersions,Y[U.a.IPYWIDGET_RENDER_FAILURE]=N.a.handleIPyWidgetRenderFailure,Y[_.b.Undo]=Z.undo,Y[_.b.Redo]=Z.redo,Y[_.b.StartCell]=P.startCell,Y[_.b.FinishCell]=P.finishCell,Y[_.b.UpdateCellWithExecutionResults]=P.updateCell,Y[_.b.Activate]=N.a.activate,Y[_.b.RestartKernel]=B.a.handleRestarted,Y[A.a.GetCssResponse]=N.a.handleCss,Y[_.b.MonacoReady]=N.a.monacoReady,Y[A.a.GetMonacoThemeResponse]=N.a.monacoThemeChange,Y[_.b.GetAllCells]=K.a.getAllCells,Y[_.b.ExpandAll]=H.expandAll,Y[_.b.CollapseAll]=H.collapseAll,Y[_.b.DeleteAllCells]=P.deleteAllCells,Y[_.b.StartProgress]=N.a.startProgress,Y[_.b.StopProgress]=N.a.stopProgress,Y[A.b.UpdateSettings]=H.updateSettings,Y[_.b.StartDebugging]=Z.startDebugging,Y[_.b.StopDebugging]=Z.stopDebugging,Y[_.b.ScrollToCell]=H.scrollToCell,Y[_.b.UpdateKernel]=B.a.updateStatus,Y[A.b.LocInit]=N.a.handleLocInit,Y[_.b.UpdateDisplayData]=N.a.handleUpdateDisplayData,Y);var re,ae,ne,le,se=Object(i.a)(),ie=window.inTestMode,pe=!ie&&"undefined"!=typeof acquireVsCodeApi,ce=new s.a,de=(re=pe,ae=se,ne=ie,le=ce,L.a(re,ae,ne,!1,oe,le)),ue=Object(n.b)(D,I.a)(R);a.render(r.createElement(n.a,{store:de},r.createElement(ue,null),r.createElement(l.a,{postOffice:ce,widgetContainerId:"rootWidget",store:de})),document.getElementById("root"))},Zytl:function(e,t,o){var r=o("+oPt");"string"==typeof r&&(r=[[e.i,r,""]]);var a={hmr:!0,transform:void 0,insertInto:void 0};o("aET+")(r,a);r.locals&&(e.exports=r.locals)},vOLz:function(e,t){e.exports=log4js}});
//# sourceMappingURL=interactiveWindow.js.map