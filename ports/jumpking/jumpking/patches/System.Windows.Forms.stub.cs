using System;

[assembly: System.Reflection.AssemblyVersion("4.0.0.0")]
[assembly: System.Reflection.AssemblyFileVersion("4.0.0.0")]

namespace System.Windows.Forms
{
    public enum MessageBoxButtons { OK, OKCancel, AbortRetryIgnore, YesNoCancel, YesNo, RetryCancel }
    public enum MessageBoxIcon { None, Hand, Stop = Hand, Error = Hand, Question, Exclamation, Warning = Exclamation, Asterisk, Information = Asterisk }
    public enum MessageBoxDefaultButton { Button1, Button2, Button3 }
    public enum DialogResult { None, OK, Cancel, Abort, Retry, Ignore, Yes, No }

    /// <summary>
    /// Headless replacement for the Windows Forms message box: logs the text and
    /// returns at once, so ports never need X11/WinForms/gdiplus at runtime.
    /// </summary>
    public static class MessageBox
    {
        static DialogResult ShowCore(string text, string caption)
        {
            Console.Error.WriteLine("[MessageBox] " + (caption ?? "") + ": " + (text ?? ""));
            return DialogResult.OK;
        }
        public static DialogResult Show(string text) { return ShowCore(text, null); }
        public static DialogResult Show(string text, string caption) { return ShowCore(text, caption); }
        public static DialogResult Show(string text, string caption, MessageBoxButtons buttons) { return ShowCore(text, caption); }
        public static DialogResult Show(string text, string caption, MessageBoxButtons buttons, MessageBoxIcon icon) { return ShowCore(text, caption); }
        public static DialogResult Show(string text, string caption, MessageBoxButtons buttons, MessageBoxIcon icon, MessageBoxDefaultButton defaultButton) { return ShowCore(text, caption); }
    }
}
