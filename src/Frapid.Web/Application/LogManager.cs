﻿using System;
using System.IO;
using System.Web.Hosting;
using Frapid.Configuration;
using Serilog;
using Serilog.Core;
using Serilog.Events;

namespace Frapid.Web
{
    internal static class LogManager
    {
        private static string GetLogDirectory()
        {
            string path = ConfigurationManager.GetConfigurationValue("ParameterConfigFileLocation",
                "ApplicationLogDirectory");

            if (string.IsNullOrWhiteSpace(path))
            {
                return HostingEnvironment.MapPath("~/Resource/Temp");
            }

            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }

            return path;
        }

        private static string GetLogFileName()
        {
            string applicationLogDirectory = GetLogDirectory();
            string filePath = Path.Combine(applicationLogDirectory,
                DateTime.Now.Date.ToShortDateString().Replace(@"/", "-"), "log.txt");
            return filePath;
        }

        private static LoggerConfiguration GetConfiguration()
        {
            string minimumLogLevel = ConfigurationManager.GetConfigurationValue("ParameterConfigFileLocation",
                "MinimumLogLevel");

            var levelSwitch = new LoggingLevelSwitch();

            LogEventLevel logLevel;
            Enum.TryParse(minimumLogLevel, out logLevel);

            levelSwitch.MinimumLevel = logLevel;

            return
                new LoggerConfiguration().MinimumLevel.ControlledBy(levelSwitch)
                    .WriteTo.RollingFile(GetLogFileName());
        }

        internal static void InternalizeLogger()
        {
            Log.Logger = GetConfiguration().CreateLogger();

            Log.Information("Application started.");
        }
    }
}