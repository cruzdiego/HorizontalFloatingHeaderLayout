//
//  HorizontalFloatingHeaderLayout.swift
//  Pods
//
//  Created by Diego Alberto Cruz Castillo on 12/30/15.
//
//

import UIKit

@objc public protocol HorizontalFloatingHeaderLayoutDelegate: class{
    //Item size
    func collectionView(_ collectionView: UICollectionView,horizontalFloatingHeaderItemSizeAt indexPath:IndexPath) -> CGSize
    
    //Header size
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSizeAt section: Int) -> CGSize
    
    //Section Inset
    @objc optional func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetAt section: Int) -> UIEdgeInsets
    
    //Item Spacing
    @objc optional func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAt section: Int) -> CGFloat
    
    //Line Spacing
    @objc optional func collectionView(_ collectionView: UICollectionView,horizontalFloatingHeaderColumnSpacingForSectionAt section: Int) -> CGFloat
}

public class HorizontalFloatingHeaderLayout: UICollectionViewLayout {
    //MARK: - Properties
    public override var collectionViewContentSize: CGSize {
        get{
            return getContentSize()
        }
    }
    
    //MARK: Headers properties
    //Variables
    private var sectionHeadersAttributes: [IndexPath:UICollectionViewLayoutAttributes]{
        get{
            return getSectionHeadersAttributes()
        }
    }
    //MARK: Items properties
    //Variables
    private var itemsAttributes = [IndexPath:UICollectionViewLayoutAttributes]()
    //PrepareItemsAtributes only
    private var currentMinX:CGFloat = 0
    private var currentMinY:CGFloat = 0
    private var currentMaxX:CGFloat = 0
    
    //MARK: - PrepareForLayout methods
    public override func prepare() {
        prepareItemsAttributes()
    }
    
    //Items
    private func prepareItemsAttributes(){
        func resetAttributes(){
            itemsAttributes.removeAll()
            currentMinX = 0
            currentMaxX = 0
            currentMinY = 0
        }
        
        func configureVariables(forSection section:Int){
            let sectionInset = inset(ForSection: section)
            let lastSectionInset = inset(ForSection: section - 1)
            currentMinX = (currentMaxX + sectionInset.left + lastSectionInset.right)
            currentMinY = sectionInset.top + headerSize(forSection: section).height
            currentMaxX = 0.0
        }
        
        func itemAttribute(at indexPath:IndexPath)->UICollectionViewLayoutAttributes{
            //Applying corrected layout
            func newLineOrigin(size:CGSize)->CGPoint{
                var origin = CGPoint.zero
                origin.x = currentMaxX + columnSpacing(forSection: indexPath.section)
                origin.y = inset(ForSection: indexPath.section).top + headerSize(forSection: indexPath.section).height
                return origin
            }
            
            func sameLineOrigin(size:CGSize)->CGPoint{
                var origin = CGPoint.zero
                origin.x = currentMinX
                origin.y = currentMinY
                return origin
            }
            
            func updateVariables(itemFrame frame:CGRect){
                currentMaxX = max(currentMaxX,frame.maxX)
                currentMinX = frame.minX
                currentMinY = frame.maxY + itemSpacing(forSection: indexPath.section)
            }
            
            //
            let size = itemSize(for: indexPath)
            let newMaxY = currentMinY + size.height
            let origin:CGPoint
            if newMaxY >  availableHeight(atSection: indexPath.section){
                origin = newLineOrigin(size: size)
            }else{
                origin = sameLineOrigin(size: size)
            }
            let frame = CGRect(x:origin.x, y:origin.y, width:size.width, height:size.height)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = frame
            updateVariables(itemFrame: frame)
            return attribute
        }
        
        //
        guard let collectionView = collectionView else {
            return
        }
        
        resetAttributes()
        let sectionCount = collectionView.numberOfSections
        guard sectionCount > 0 else {
            return
        }
        
        for section in 0..<sectionCount {
            configureVariables(forSection: section)
            let itemCount = collectionView.numberOfItems(inSection:section)
            guard itemCount > 0 else {
                continue
            }
            
            for index in 0..<itemCount {
                let indexPath = IndexPath(row: index, section: section)
                let attribute = itemAttribute(at: indexPath)
                itemsAttributes[indexPath] = attribute
            }
        }
    }
    
    //MARK: - LayoutAttributesForElementsInRect methods
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        func attributes(_ attributes:[IndexPath:UICollectionViewLayoutAttributes],containedIn rect:CGRect) -> [UICollectionViewLayoutAttributes]{
            var finalAttributes = [UICollectionViewLayoutAttributes]()
            for (_,attribute) in attributes{
                if rect.intersects(attribute.frame){
                    finalAttributes.append(attribute)
                }
            }
            
            return finalAttributes
        }
        
        //
        let itemsA = attributes(itemsAttributes, containedIn: rect)
        let headersA = Array(sectionHeadersAttributes.values)
        return itemsA + headersA
    }
    
    //MARK: - ContentSize methods
    private func getContentSize() -> CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        func lastItemMaxX()->CGFloat{
            let lastSection = collectionView.numberOfSections - 1
            let lastIndexInSection = collectionView.numberOfItems(inSection:lastSection) - 1
            if let lastItemAttributes = layoutAttributesForItem(at: IndexPath(row: lastIndexInSection, section: lastSection)){
                return lastItemAttributes.frame.maxX
            }else{
                return 0
            }
        }
        //
        let lastSection = collectionView.numberOfSections - 1
        let contentWidth = lastItemMaxX() + inset(ForSection: lastSection).right
        let contentHeight = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        return CGSize(width:contentWidth, height:contentHeight)
    }
    
    //MARK: - LayoutAttributes methods
    //MARK: For ItemAtIndexPath
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let fromIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        return itemsAttributes[fromIndexPath]
    }
    //MARK: For SupplementaryViewOfKind
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            let fromIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            return sectionHeadersAttributes[fromIndexPath]
        default:
            return nil
        }
    }
    
    //MARK: - Utility methods
    //MARK: SectionHeaders Attributes methods
    private func getSectionHeadersAttributes()->[IndexPath:UICollectionViewLayoutAttributes]{
        func attributeForSectionHeader(at indexPath:IndexPath) -> UICollectionViewLayoutAttributes{
            func size()->CGSize{
                return headerSize(forSection: indexPath.section)
            }
            //
            func position()->CGPoint{
                if let itemsCount = collectionView?.numberOfItems(inSection: indexPath.section),
                    let firstItemAttributes = layoutAttributesForItem(at: indexPath),
                    let lastItemAttributes = layoutAttributesForItem(at: IndexPath(row: itemsCount-1, section: indexPath.section)){
                        let edgeX = collectionView!.contentOffset.x + collectionView!.contentInset.left
                        let xByLeftBoundary = max(edgeX,firstItemAttributes.frame.minX)
                        //
                        let width = size().width
                        let xByRightBoundary = lastItemAttributes.frame.maxX - width
                        let x = min(xByLeftBoundary,xByRightBoundary)
                    return CGPoint(x:x, y:0)
                }else{
                    return CGPoint(x:inset(ForSection: indexPath.section).left, y:0)
                }
            }
            //
            let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
            let myPosition = position()
            let mySize = size()
            let frame = CGRect(x:myPosition.x, y:myPosition.y, width: mySize.width, height: mySize.height)
            attribute.frame = frame
            
            return attribute
        }
        //
        guard let collectionView = collectionView else {
            return [:]
        }
        
        let sectionCount = collectionView.numberOfSections
        guard sectionCount > 0 else {
            return [:]
        }
        
        var attributes = [IndexPath:UICollectionViewLayoutAttributes]()
        for section in 0..<sectionCount {
            let indexPath = IndexPath(row: 0, section: section)
            attributes[indexPath] = attributeForSectionHeader(at: indexPath)
        }
        
        return attributes
    }
    
    //MARK: - Invalidating layout methods
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        func isSizeChanged()->Bool{
            let oldBounds = collectionView!.bounds
            return oldBounds.width != newBounds.width || oldBounds.height != newBounds.height
        }
        
        func headersIndexPaths()->[IndexPath]{
            return Array(sectionHeadersAttributes.keys)
        }
        
        //
        let context = super.invalidationContext(forBoundsChange: newBounds)
        if !isSizeChanged(){
            context.invalidateSupplementaryElements(ofKind: UICollectionElementKindSectionHeader, at: headersIndexPaths())
        }
        return context
    }
    
    //MARK: - Utility methods
    private func itemSize(for indexPath:IndexPath) -> CGSize{
        guard   let collectionView = collectionView,
                let delegate = collectionView.delegate as? HorizontalFloatingHeaderLayoutDelegate else {
            return CGSize.zero
        }
        
        return delegate.collectionView(collectionView, horizontalFloatingHeaderItemSizeAt: indexPath)
    }
    
    private func headerSize(forSection section:Int) -> CGSize{
        guard   let collectionView = collectionView,
                let delegate = collectionView.delegate as? HorizontalFloatingHeaderLayoutDelegate,
                section >= 0 else {
                return CGSize.zero
        }
        
        return delegate.collectionView(collectionView, horizontalFloatingHeaderSizeAt: section)
    }
    
    private func inset(ForSection section:Int) -> UIEdgeInsets{
        let defaultValue = UIEdgeInsets.zero
        guard   let collectionView = collectionView,
                let delegate = collectionView.delegate as? HorizontalFloatingHeaderLayoutDelegate,
                section >= 0 else {
                return defaultValue
        }
        
        return delegate.collectionView?(collectionView, horizontalFloatingHeaderSectionInsetAt: section) ?? defaultValue
    }
    
    private func columnSpacing(forSection section:Int) -> CGFloat{
        let defaultValue:CGFloat = 0.0
        guard   let collectionView = collectionView,
                let delegate = collectionView.delegate as? HorizontalFloatingHeaderLayoutDelegate,
                section >= 0 else {
                return defaultValue
        }
        
        return delegate.collectionView?(collectionView, horizontalFloatingHeaderColumnSpacingForSectionAt: section) ?? defaultValue
    }
    
    private func itemSpacing(forSection section:Int) -> CGFloat{
        let defaultValue:CGFloat = 0.0
        guard   let collectionView = collectionView,
                let delegate = collectionView.delegate as? HorizontalFloatingHeaderLayoutDelegate,
                section >= 0 else {
                return defaultValue
        }
        
        return delegate.collectionView?(collectionView, horizontalFloatingHeaderItemSpacingForSectionAt: section) ?? defaultValue
    }
    
    private func availableHeight(atSection section:Int)->CGFloat{
        guard let collectionView = collectionView else {
            return 0.0
        }
        
        func totalInset()->CGFloat{
            let sectionInset = inset(ForSection: section)
            let contentInset = collectionView.contentInset
            return sectionInset.top + sectionInset.bottom + contentInset.top + contentInset.bottom
        }
        
        //
        guard section >= 0 else {
            return 0.0
        }
        
        return collectionView.bounds.height - totalInset()
    }
}
