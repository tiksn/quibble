using Autofac;
using Autofac.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Serilog;

namespace TIKSN.quibble
{
    public class Program
    {
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .UseServiceProviderFactory(new AutofacServiceProviderFactory())
                .ConfigureServices((hostContext, services) =>
                {
                    services.AddAutofac();
                    services.AddHostedService<Worker>();
                })
                .ConfigureContainer<ContainerBuilder>(builder =>
                {
                    // registering services in the Autofac ContainerBuilder
                })
                .ConfigureLogging(builder =>
                {
                    builder.ClearProviders();
                    var logger = new LoggerConfiguration()
                        .WriteTo.ColoredConsole()
                        .CreateLogger();
                    builder.AddSerilog(logger);
                })
                .UseConsoleLifetime();

        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }
    }
}