package uni.dcloud.io.uniplugin_richalert;

import android.app.Activity;
import android.content.DialogInterface;
import android.graphics.Color;
import android.text.TextUtils;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKEngine;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.utils.WXLogUtils;
import com.taobao.weex.utils.WXResourceUtils;

public class RichAlertWXModule extends WXSDKEngine.DestroyableModule {
    public String CONTENT = "content";
    public String CONTENT_COLOR  = "contentColor";
    public String CONTENT_ALIGN  = "contentAlign";
    public String POSITION = "position";
    public String BUTTONS = "buttons";
    public String CHECKBOX = "checkBox";
    public String TITLE_ALIGN = "titleAlign";
    //默认黑色
    public static int defColor = Color.BLACK;

    RichAlert alert;

    @JSMethod(uiThread = true)
    public void show(JSONObject options, JSCallback jsCallback) {
        if (mWXSDKInstance.getContext() instanceof Activity) {
            String content = options.getString(CONTENT);
            int contentColor = WXResourceUtils.getColor(options.getString(CONTENT_COLOR), defColor);
            String contentAlign = options.getString(CONTENT_ALIGN);

            String title = options.getString(RichAlert.TITLE);
            int titleColor = WXResourceUtils.getColor(options.getString(RichAlert.TITLE_COLOR), defColor);
            String titleAlign = options.getString(TITLE_ALIGN);

            String postion = options.getString(POSITION);

            RichAlert richAlert = new RichAlert(mWXSDKInstance.getContext());

            JSONArray buttons = options.getJSONArray(BUTTONS);
            JSONObject checkBox = options.getJSONObject(CHECKBOX);

            if(!TextUtils.isEmpty(title)) {
                richAlert.setTitle(title, titleColor, titleAlign);
            }
            if(!TextUtils.isEmpty(content)) {
                richAlert.setContent(content, contentColor, contentAlign,jsCallback);
            }
            if(checkBox != null) {
                richAlert.setCheckBox(checkBox, jsCallback);
            }
            if(buttons != null) {
                richAlert.setButtons(buttons, jsCallback);
            }
            if(!TextUtils.isEmpty(postion)) {
                richAlert.setPosition(postion);
            }

            richAlert.show();
            tracking(richAlert, jsCallback);
        }
    }

    private void tracking(RichAlert dialog, final JSCallback jsCallback) {
        alert = dialog;
        dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                JSONObject result = new JSONObject();
                result.put("type", "backCancel");
                jsCallback.invoke(result);
            }
        });
        dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                alert = null;
            }
        });
    }

    @JSMethod(uiThread = true)
    public void dismiss() {
        destroy();
    }

    @Override
    public void destroy() {
        if (alert != null && alert.isShowing()) {
            WXLogUtils.w("Dismiss the active dialog");
            alert.dismiss();
        }
    }

}
