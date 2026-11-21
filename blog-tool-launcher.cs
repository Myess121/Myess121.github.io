// Compile as a Windows application with System.Management.Automation.dll.
// The GUI and operations live in blog-tool.ps1 beside this executable.
using System;
using System.IO;
using System.Management.Automation;
using System.Windows.Forms;

internal static class BlogToolLauncher
{
    [STAThread]
    private static void Main(string[] args)
    {
        try
        {
            string folder = AppDomain.CurrentDomain.BaseDirectory;
            string script = Path.Combine(folder, "blog-tool.ps1");
            if (!File.Exists(script))
                throw new FileNotFoundException("Missing blog-tool.ps1 beside this application.");
            using (PowerShell shell = PowerShell.Create())
            {
                shell.AddCommand(script).AddParameter("ProjectRoot", args.Length > 0 ? args[0] : folder);
                shell.Invoke();
                if (shell.HadErrors)
                {
                    string message = "";
                    foreach (ErrorRecord error in shell.Streams.Error)
                        message += error.ToString() + Environment.NewLine;
                    MessageBox.Show(message, "Blog Tool", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }
        catch (Exception error)
        {
            MessageBox.Show(error.Message, "Blog Tool", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
