using Microsoft.EntityFrameworkCore;
using DealzParkApi.Models;

namespace DealzParkApi.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {

        }

        public DbSet<Shop> Shops { get; set; }
        public DbSet<Offer> Offers { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Shop>()
                .HasMany(s => s.Offers)
                .WithOne(o => o.Shop)
                .HasForeignKey(o => o.ShopId)
                .OnDelete(DeleteBehavior.Cascade); // If a shop is deleted, its offers are deleted

            // Seed some categories for OfferCategory enum
            modelBuilder.Entity<Offer>()
                .Property(o => o.Category)
                .HasConversion<string>(); // Store enum as string
        }
    }
}