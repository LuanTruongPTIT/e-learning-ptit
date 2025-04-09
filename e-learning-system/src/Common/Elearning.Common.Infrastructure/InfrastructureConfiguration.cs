
using Common.Elearning.Infrastructure.Clock;
using Dapper;
using Elearning.Common.Application.Clock;
using Elearning.Common.Application.Data;
using Elearning.Common.Application.EventBus;
using Elearning.Common.Infrastructure.Data;
using Elearning.Common.Infrastructure.Outbox;
using MassTransit;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Npgsql;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Quartz;
using StackExchange.Redis;

namespace Elearning.Common.Infrastructure;

public static class InfrastructureConfiguration
{
  public static IServiceCollection AddInfrastructure(
    this IServiceCollection services,
    string serviceName,
    // Action<IRegistrationConfigurator>[] moduleConfigureConsumers,
    string databaseConnectionString,
    string redisConnectionString,
  string rabbitmqConnectionString
  )
  {
    services.TryAddSingleton<IDateTimeProvider, DateTimeProvider>();

    services.TryAddSingleton<IEventBus, EventBus.EventBus>();
    services.TryAddSingleton<InsertOutboxMessagesInterceptor>();

    NpgsqlDataSource npgsqlDataSource = new NpgsqlDataSourceBuilder(databaseConnectionString).Build();
    services.TryAddSingleton(npgsqlDataSource);

    services.TryAddScoped<IDbConnectionFactory, DbConnectionFactory>();

    SqlMapper.AddTypeHandler(new GenericArrayHandler<string>());

    services.AddQuartz(configurator =>
    {
      var scheduler = Guid.NewGuid();
      configurator.SchedulerId = $"default-id-{scheduler}";
      configurator.SchedulerName = $"default-name-{scheduler}";
    });

    services.AddQuartzHostedService(options => options.WaitForJobsToComplete = true);

    try
    {
      IConnectionMultiplexer connectionMultiplexer = ConnectionMultiplexer.Connect(redisConnectionString);
      services.AddSingleton(connectionMultiplexer);
      services.AddStackExchangeRedisCache(options =>
         options.ConnectionMultiplexerFactory = () => Task.FromResult(connectionMultiplexer)
      );
    }
    catch
    {
      services.AddDistributedMemoryCache();
    }

    services.AddMassTransit(configure =>
    {
      // foreach (Action<IRegistrationConfigurator> configureConsumers in moduleConfigureConsumers)
      // {
      //   configureConsumers(configure);
      // }
      configure.SetKebabCaseEndpointNameFormatter();

      configure.UsingRabbitMq((context, cfg) =>
      {
        cfg.Host(rabbitmqConnectionString, host =>
        {
          host.Username("user");
          host.Password("user");
        });
        cfg.ConfigureEndpoints(context);
      });
    });

    services.AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService(serviceName))
    .WithTracing(tracing =>
    {
      tracing
          .AddAspNetCoreInstrumentation()
          .AddHttpClientInstrumentation()
          .AddEntityFrameworkCoreInstrumentation()
          .AddRedisInstrumentation()
          // .AddMassTransitInstrumentation()
          .AddNpgsql()
      .AddSource(MassTransit.Logging.DiagnosticHeaders.DefaultListenerName);

      tracing.AddOtlpExporter();
    });
    return services;
  }
}