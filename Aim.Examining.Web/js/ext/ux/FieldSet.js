    Ext.onReady(function() {   
    Ext.QuickTips.init();   
    Ext.form.Field.prototype.msgTarget = 'side';   
    // Fix 2.1 bug   
    Ext.override(Ext.layout.FormLayout, {   
                getAnchorViewSize : function(ct, target) {   
                    return (ct.body || ct.el).getStyleSize();   
                }   
            });   
    var cc=Ext.apply({item:[]},{sdf:'sd'});   
    alert(cc.toString());   
    new Ext.form.FormPanel({   
        renderTo : document.body,   
        title : "·´À¡Òâ¼û",   
        border : false,   
        renderto : Ext.getBody(),   
        bodyStyle : "padding: 8px; background-color: transparent;",   
        labelAlign : "left",   
        labelWidth : 150,   
        autoScroll : true,   
        defaultType : "textfield",   
        items : [{   
                    xtype : "fieldset",   
                    autoHeight : true,   
                    title : "Search",   
                    layout : "column",   
                    items : [{   
                                xtype : 'container',   
                                autoEl : {},   
                                columnWidth : 0.5,   
                                layout : 'form',   
                                items : new Ext.form.DateField({   
                                    autoCreate : {   
                                        tag : "input",   
                                        type : "text",   
                                        size : 8  
                                    },   
                                    fieldLabel : "Start Date",   
                                    blankText : "Start Date...",   
                                    format : "Y-m-d",   
                                    value : ""  
                                    // ,   
                                    // disabled : true   
                                })   
                            }, {   
                                xtype : 'container',   
                                autoEl : {},   
                                columnWidth : 0.5,   
                                layout : 'form',   
                                defaultType : 'textfield',   
                                items : [{   
                                    fieldLabel : 'Field 3'  
  
                                },{   
                                    fieldLabel : 'Field 4'  
  
                                }]   
                                // new Ext.form.DateField({   
                            // autoCreate : {   
                            // tag : "input",   
                            // type : "text",   
                            // size : 8   
                            // },   
                            // fieldLabel : "Start Date",   
                            // blankText : "Start Date...",   
                            // format : "Y-m-d",   
                            // value : "",   
                            // disabled : true   
                            // })   
                        }]   
                }, {   
                    xtype : "fieldset",   
                    title : "Recurring"  
                }]   
    });   
});  
