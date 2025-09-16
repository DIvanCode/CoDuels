using Duely.Application.UseCases;
using Duely.Infrastructure.DataAccess.EntityFramework;

var builder = WebApplication.CreateBuilder(args);

builder.Services.SetupUseCases();

builder.Services.SetupDataAccessEntityFramework(builder.Configuration);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseAuthorization();

app.MapControllers();

app.Run();