package uni.dcloud.io.uniplugin_richalert;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.utils.WXResourceUtils;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.util.ArrayList;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import uni.dcloud.io.uniplugin_richalert.Info.Person;
import uni.dcloud.io.uniplugin_richalert.Info.SaxHelper;


public class RichAlert {

    public static String TITLE = "title";
    public static String TITLE_COLOR = "titleColor";

    int mTitleColor = Color.BLACK;
    int mTitleAlign = Gravity.CENTER;
    int mPositiveColor = Color.BLACK;
    int mNegativeColor = Color.BLACK;
    int mNeutralColor = Color.BLACK;
    int mPosition = Gravity.CENTER;
    Context mContext;
    CheckBox mCheckBox;
    TextView mMessageView;
    AlertDialog mAlertDialog;
    AlertDialog.Builder mBuilder;
    LinearLayout mMessageViewRootView;

    String SELECTED = "isSelected";

    public RichAlert(@NonNull Context context) {
        mContext = context;
        mBuilder = new AlertDialog.Builder(context);
    }

    /**
     * 显示弹窗
     */
    public void show() {
        mAlertDialog = mBuilder.create();
        if(mMessageViewRootView != null) {
            mAlertDialog.setView(mMessageViewRootView);
            if(mCheckBox != null) {
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                layoutParams.leftMargin = dip2px(mContext, 11);
                mMessageViewRootView.addView(mCheckBox, layoutParams);
            }
        }

        mAlertDialog.setCanceledOnTouchOutside(false);
        mAlertDialog.show();

        setButtonColor(AlertDialog.BUTTON_POSITIVE, mPositiveColor);
        setButtonColor(AlertDialog.BUTTON_NEGATIVE, mNegativeColor);
        setButtonColor(AlertDialog.BUTTON_NEUTRAL, mNeutralColor);

        initTitle();

        Window dialogWindow = mAlertDialog.getWindow();//获取window对象
        dialogWindow.setGravity(mPosition);
    }


    private void initTitle() {
        Field mAlert = null;
        try {
            mAlert = AlertDialog.class.getDeclaredField("mAlert");
            mAlert.setAccessible(true);
            Object mAlertController = mAlert.get(mAlertDialog);
            Field mTitle = mAlertController.getClass().getDeclaredField("mTitleView");
            mTitle.setAccessible(true);
            TextView mTitleView = (TextView) mTitle.get(mAlertController);
            if(mTitleView != null) {
                mTitleView.setTextColor(mTitleColor);
                mTitleView.setGravity(mTitleAlign | Gravity.CENTER_VERTICAL);
                mTitleView.setPadding(dip2px(mContext, 16), 0, dip2px(mContext, 16), 0);
            }
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }

    }


    /**
     * 设置弹窗标题
     * @param title
     * @param Color
     * @return
     */
    public RichAlert setTitle(CharSequence title, int Color, String align) {
        mBuilder.setTitle(title);
        mTitleAlign = getAlign(align);
        mTitleColor = Color;
        return this;
    }

    /**
     * 设置弹窗主显示内容
     * @param content
     * @param Color
     * @param jsCallback
     * @return
     */
    public RichAlert setContent(String content, int Color, String align, JSCallback jsCallback) {
        try {
            initMessageView(mContext);
            ArrayList<Person> data = readxmlForDom(content);
            if(data != null && data.size() > 0) {
                CharSequence ct = getContentCharSequence(data, jsCallback);
                mMessageView.setText(ct);
            } else {
                mMessageView.setText(content);
            }
            mMessageView.setTextColor(Color);
            mMessageView.setGravity(getAlign(align));

        } catch (Exception e) {
            e.printStackTrace();
        }
        return this;
    }

    private void initMessageView(Context context) {
        if(mMessageViewRootView == null) {
            mMessageViewRootView = new LinearLayout(context);
            mMessageViewRootView.setOrientation(LinearLayout.VERTICAL);
            ScrollView scrollView = new ScrollView(context);
            mMessageView = new TextView(context);
            ScrollView.LayoutParams params = new ScrollView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            params.topMargin = dip2px(context, 32);
            params.bottomMargin = dip2px(context, 32);
            params.leftMargin = dip2px(context, 16);
            params.rightMargin = dip2px(context, 16);
            mMessageViewRootView.addView(scrollView, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, 1));
            scrollView.addView(mMessageView, params);
            mMessageView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
            mMessageView.setMovementMethod(LinkMovementMethod.getInstance());
        }
    }

    /**
     * 设置弹窗按钮
     * @param buttons
     * @param jsCallback
     * @return
     */
    public RichAlert setButtons(JSONArray buttons, final JSCallback jsCallback) {
        if(buttons != null && buttons.size() > 0) {
            for(int i = 0; i < buttons.size();i++) {
                JSONObject button = buttons.getJSONObject(i);
                String title = button.getString(TITLE);
                int color = WXResourceUtils.getColor(button.getString(TITLE_COLOR), RichAlertWXModule.defColor);
                if(TextUtils.isEmpty(title)) {
                    continue;
                }
                if(i > 2) { //buttons 最多支持三个button
                    return this;
                }
                final int index = i;
                DialogInterface.OnClickListener listener =  new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int n) {
                        JSONObject result = new JSONObject();
                        result.put("type", "button");
                        result.put("index", index);
                        jsCallback.invoke(result);
                    }
                };
                switch(i) {
                    case 0: {
                        mBuilder.setNegativeButton(title, listener);
                        mNegativeColor = color;
                        break;
                    }
                    case 1: {
                        mBuilder.setNeutralButton(title, listener);
                        mNeutralColor = color;
                        break;
                    }
                    case 2: {
                        mBuilder.setPositiveButton(title, listener);
                        mPositiveColor = color;
                        break;
                    }
                }
            }
        }
        return this;
    }


    /**
     * 设置按钮文字颜色
     * 需要在show操作之后调用
     * @param type
     * @param color
     */
    private void setButtonColor(int type, int color) {
        if(mAlertDialog != null) {
            Button button = mAlertDialog.getButton(type);
            if(button != null) {
                button.setTextColor(color);
            }
        }
    }

    /**
     * 提示框位置
     * @param position
     * @return
     */
    public RichAlert setPosition(String position) {
        mPosition = getAlign(position);
        return this;
    }

    /**
     * 设置复选框提示
     * @param checkBox
     * @param jsCallback
     * @return
     */
    public RichAlert setCheckBox(JSONObject checkBox, final JSCallback jsCallback) {
        if(checkBox == null) {
            return this;
        }
        mCheckBox = new CheckBox(mContext);

        mCheckBox.setText(checkBox.getString(TITLE));
        int color = WXResourceUtils.getColor(checkBox.getString(TITLE_COLOR), RichAlertWXModule.defColor);
        mCheckBox.setTextColor(color);
        boolean isSelected = false;
        if(checkBox.containsKey(SELECTED)) {
            isSelected = checkBox.getBoolean(SELECTED);
        }
        mCheckBox.setChecked(isSelected);
        mCheckBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                JSONObject result = new JSONObject();
                result.put("type", "checkBox");
                result.put("isSelected", isChecked);
                jsCallback.invokeAndKeepAlive(result);
            }
        });
        return this;
    }


    /**
     * 将Person转换对应的Span
     * @param data
     * @param jsCallback
     * @return
     */
    private CharSequence getContentCharSequence(ArrayList<Person> data, JSCallback jsCallback) {
        SpannableStringBuilder spannableString = new SpannableStringBuilder();
        for(Person person : data) {
            if(TextUtils.isEmpty(person.content)) {
                continue;
            }
            if(person.label.equalsIgnoreCase("a")) {
                setASpan(spannableString, person, jsCallback);
            } else {
                spannableString.append(person.content);
            }
        }

        return spannableString;
    }

    /**
     * 设置A标签指定的Span 包含点击事件
     * @param spannableString
     * @param person
     * @param jsCallback
     */
    private void setASpan(SpannableStringBuilder spannableString, final Person person, final JSCallback jsCallback) {
        int start = spannableString.toString().length();
        spannableString.append(person.content);
        int end = spannableString.toString().length();
        ClickableSpan clickableSpan = new ClickableSpan() {

            public void onClick(View view) {
                //Do something with URL here.
                JSONObject result = new JSONObject();
                result.put("type", "a");
                result.putAll(person.attribute);
                jsCallback.invokeAndKeepAlive(result);
            }
        };
        spannableString.setSpan(clickableSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        ForegroundColorSpan foregroundColorSpan=new ForegroundColorSpan(Color.BLUE);
        spannableString.setSpan(foregroundColorSpan,start,end,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
    }

    /**
     * 解析XML 获取person数组
     * @param content
     * @return
     * @throws Exception
     */
    private ArrayList<Person> readxmlForDom(String content) throws Exception {
        content = "<RichP>" + content + "</RichP>";
        //获取文件资源建立输入流对象
        InputStream is = new ByteArrayInputStream(content.getBytes());
        //创建一个SAXParserFactory解析器工程
        SAXParserFactory factory = SAXParserFactory.newInstance();
        SaxHelper helper = new SaxHelper();
        //③创建SAX解析器
        SAXParser parser = factory.newSAXParser();
        parser.parse(is, helper);
        return helper.getPersons();
    }

    public boolean isShowing() {
        return mAlertDialog == null ? false : mAlertDialog.isShowing();
    }

    public void dismiss() {
        if(mAlertDialog != null) {
            mAlertDialog.dismiss();
            mAlertDialog = null;
            mMessageViewRootView = null;
            mMessageView = null;
            mCheckBox = null;
        }
    }

    public void setOnDismissListener(DialogInterface.OnDismissListener listener) {
        if(mAlertDialog != null)
            mAlertDialog.setOnDismissListener(listener);
    }

    public void setOnCancelListener(DialogInterface.OnCancelListener listener) {
        if(mAlertDialog != null)
            mAlertDialog.setOnCancelListener(listener);
    }

    private int dip2px(Context context, float dipValue) {
        float scale =  context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }

    private int getAlign(String alignString) {
        int align = Gravity.CENTER;
        if(!TextUtils.isEmpty(alignString)) {
            switch (alignString) {
                case "left":
                    align = Gravity.LEFT;
                    break;
                case "right" :
                    align = Gravity.RIGHT;
                    break;
                case "bottom":
                    align = Gravity.BOTTOM;
                    break;
            }
        }
        return align;
    }
}
