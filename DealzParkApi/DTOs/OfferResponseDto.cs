using DealzParkApi.Models;

namespace DealzParkApi.DTOs
{
    public class OfferResponseDto
    {
        public int Id { get; set; }
        public string PromotionalTitle { get; set; }
        public string? PromotionalImageUrl { get; set; }
        public int DiscountPercentage { get; set; }
        public string? ProductImageUrl { get; set; }
        public DateTime ValidFrom { get; set; }
        public DateTime ValidTo { get; set; }
        public DateTime CreatedAt { get; set; }
        public string Category { get; set; } // String representation of enum
        public int ShopId { get; set; }
        public string ShopName { get; set; }
    }
}